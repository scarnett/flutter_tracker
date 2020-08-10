import * as admin from 'firebase-admin'
import * as userUtils from './user-utils'
import * as groupUtils from './group-utils'
import * as messageUtils from './message-utils'

export enum PlaceEventType {
  ENTERING = 'entering',
  LEAVING = 'leaving'
}

export function getPlace(placeId: any): FirebaseFirestore.DocumentReference {
  return admin.firestore()
    .collection('places')
    .doc(placeId)
}

export function getPlaces(groupId: any): FirebaseFirestore.Query {
  return admin.firestore()
    .collection('places')
    .where('group', '==', groupId)
}

// Adds a new activity document to the place activity collection
export function addPlaceActivity(placeId: any, activityData: any): Promise<any> {
  return getPlace(placeId)
    .collection('activity')
    .add(activityData)
}

export async function checkPlaceGeofences(uid: string, user: any, groupId: string): Promise<any> {
  try {
    const placesSnapshot = await getPlaces(groupId).get()
    const promises: Array<Promise<any>> = []

    placesSnapshot.forEach((placeDoc: FirebaseFirestore.QueryDocumentSnapshot) => {
      const placeData: any = placeDoc.data()

      // If the user is within the place radius then update the place data
      const withinRadius: boolean = userUtils.isUserWithinPlaceRadius(user, placeData)
      if (withinRadius) {
        const groupMemberData: any = {}
        groupMemberData[uid] = {
          'place': {
            'documentId': placeDoc.id,
            'name': placeData.name || 'unknown',
            'last_updated': admin.firestore.FieldValue.serverTimestamp()
          }
        }

        // Updates the 'place' in the users' groups
        promises.push(groupUtils.syncMemberGroups(uid, groupMemberData))

        // Adds a geofence activity document to the user
        promises.push(messageUtils.addGeofenceActivity(uid, user, placeData, userUtils.UserActivityType.GEOFENCE_ENTERING))
      }
    })

    return Promise.all(promises)
  }
  catch (error) {
    console.error(error)
    return Promise.resolve(null)
  }
}

export function activatePlace(placeDoc: FirebaseFirestore.DocumentReference): Promise<FirebaseFirestore.WriteResult> {
  console.log('ACTIVATING PLACE', placeDoc.id)
  return placeDoc.set({
    'active': true,
    'last_updated': admin.firestore.FieldValue.serverTimestamp()
  }, { merge: true })
}

export async function deactivatePlace(placeDoc: FirebaseFirestore.DocumentSnapshot, group: FirebaseFirestore.DocumentReference): Promise<any> {
  try {
    const groupDoc = await group.get()
    const groupData: FirebaseFirestore.DocumentData | undefined = groupDoc.data()

    let withinRadius: boolean = false
    if (groupData) {
      // Here we're checking to see if any of the group members are within this places' geofence
      for (const memberId in groupData.members) {
        const member: any = groupData.members[memberId]
        if (!withinRadius && member && userUtils.isUserWithinPlaceRadius(member, placeDoc.data())) {
          withinRadius = true
        }
      }
    }

    if (!withinRadius) {
      console.log('DEACTIVATING PLACE', placeDoc.id)
      return placeDoc.ref.set({
        'active': false,
        'last_updated': admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true })
    }

    return Promise.resolve(null)
  }
  catch (error) {
    console.error(error)
    return Promise.resolve(null)
  }
}

export function deactivatePlaceByGroupId(placeDoc: FirebaseFirestore.DocumentSnapshot, groupId: string): Promise<any> {
  return deactivatePlace(placeDoc, groupUtils.getGroup(groupId))
}
