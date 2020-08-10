import * as admin from 'firebase-admin'
import * as userUtils from './user-utils'

export enum MessageType {
  CHECKIN = 'CHECKIN',
  JOIN_GROUP = 'JOIN_GROUP',
  LEAVE_GROUP = 'LEAVE_GROUP',
  ENTERING_GEOFENCE = 'ENTERING_GEOFENCE',
  LEAVING_GEOFENCE = 'LEAVING_GEOFENCE',
  ACCOUNT_SUBSCRIBED = 'ACCOUNT_SUBSCRIBED',
  ACCOUNT_SUBSCRIPTION_UPDATED = 'ACCOUNT_SUBSCRIPTION_UPDATED',
  ACCOUNT_UNSUBSCRIBED = 'ACCOUNT_UNSUBSCRIBED'
}

export function isType(messageData: any, type: string): boolean {
  if (messageData) {
    return (messageData.type === type)
  }

  return false
}

export async function addGeofenceActivity(uid: string, user: any, place: any, type: userUtils.UserActivityType): Promise<any> {
  if (uid && user && type) {
    try {
      const activitySnapshot = await userUtils.getActiveActivity(uid)
        .get()

      const promises: Array<Promise<any>> = []
      const now: FirebaseFirestore.FieldValue = admin.firestore.FieldValue.serverTimestamp()

      if (activitySnapshot) {
        activitySnapshot.forEach((activityDoc: FirebaseFirestore.QueryDocumentSnapshot) => {
          if (activityDoc.exists) {
            const activityData: any = activityDoc.data()
            let count: number = 0

            // Gets the current event count for this activity
            if (('events' in activityData) || Object.keys(activityData['events']).length > 0) {
              count = Object.keys(activityData['events']).length
            }

            const newEvent: any = {}
            newEvent[count++] = {
              'type': type,
              'created': now,
              'data': {
                'place': place,
                'from': userUtils.tagUser(uid, user),
              }
            }

            promises.push(activityDoc.ref.set({ 'events': newEvent }, { merge: true }))
          }
        })

        return Promise.all(promises)
      }

      return Promise.resolve(null)
    } catch (error) {
      console.error(error)
      return Promise.resolve(null)
    }
  }

  return Promise.resolve(null)
}

export function addCheckinActivities(user: FirebaseFirestore.DocumentSnapshot | null, toUser: FirebaseFirestore.DocumentSnapshot | null): Promise<any>[] {
  const promises: Promise<any>[] = []

  if (user && toUser) {
    const toUserData: any = toUser.data()
    const userData: any = user.data()
    const now: any = admin.firestore.FieldValue.serverTimestamp()

    // Creates the check-in 'sender' activity in the user document
    promises.push(admin.firestore()
      .collection('users')
      .doc(user.id)
      .collection('activity')
      .add({
        'active': false,
        'type': userUtils.UserActivityType.CHECKIN_SENDER,
        'start_time': now,
        'end_time': now,
        'last_updated': now,
        'data': {
          'from': userUtils.tagUser(user.id, userData),
          'to': userUtils.tagUser(toUser.id, toUserData)
        },
        'meta': null
      }))

    // Creates the check-in 'receiver' activity in the user document
    promises.push(admin.firestore()
      .collection('users')
      .doc(toUser.id)
      .collection('activity')
      .add({
        'active': false,
        'type': userUtils.UserActivityType.CHECKIN_RECEIVER,
        'start_time': now,
        'end_time': now,
        'last_updated': now,
        'data': {
          'from': userUtils.tagUser(user.id, userData),
          'to': userUtils.tagUser(toUser.id, toUserData)
        },
        'meta': null
      }))
  }

  return promises
}
