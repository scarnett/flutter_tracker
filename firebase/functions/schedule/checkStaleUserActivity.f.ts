import * as admin from 'firebase-admin'
import * as functions from 'firebase-functions'
import * as userUtils from '../utils/user-utils'
// import * as groupUtils from '../utils/group-utils'
import * as dateUtils from '../utils/date-utils'
import moment from 'moment-timezone'

/**
 * This checks for stale user 'activity' and then de-activates the document.
 *
 * User activity could go stale for a number of reasons but the most common I've seen
 * is when a driver abruptly looses connection by enerting a dead zone or something similar.
 */
exports = module.exports = functions.pubsub
  .schedule('every 10 minutes')
  .timeZone('America/New_York')
  .onRun(async (context: functions.EventContext) => {
    console.log('Checking for stale user activity...')

    try {
      const userSnapshot = await admin.firestore()
        .collection('users')
        .get()

      const promises: Array<Promise<any>> = []

      userSnapshot.docs.forEach((userDoc: FirebaseFirestore.QueryDocumentSnapshot) => {
        const user: any = userDoc.data()

        // TODO: FIX
        /*
        // Updates the user 'provider' if they haven't been seen in a while
        if (userUtils.checkLastLocationTimestamp(user)) {
          promises.push(userDoc.ref.set(user, { merge: true }).then(() => {
            const userId: string = userDoc.id
            const groupMemberData: any = {}
            groupMemberData[userId] = {
              // 'last_updated': admin.firestore.FieldValue.serverTimestamp(),
              'provider': user.provider
            }

            return groupUtils.syncMemberGroups(userDoc.id, groupMemberData)
          }))
        }
        */

        const activity: FirebaseFirestore.Query = userUtils.getActiveActivityFromDoc(userDoc.ref)
        promises.push(activity.get()
          .then((activitySnapshot: FirebaseFirestore.QuerySnapshot) => {
            const plist: Array<Promise<any>> = []

            if (activitySnapshot.empty) {
              updateUser(plist, userDoc, user)
            } else {
              const now: moment.Moment = moment(Date.now()).tz(user.timezone)

              activitySnapshot.forEach((activityDoc: FirebaseFirestore.QueryDocumentSnapshot) => {
                if (activityDoc.exists) {
                  const activityData: any = activityDoc.data()
                  const activityType: string = user.location.activity.type
                  const isDriving: boolean = userUtils.isDriving(activityType)
                  const lastUpdated: moment.Moment = moment(activityData.last_updated.toDate()).tz(user.timezone)
                  const diff: moment.Duration = dateUtils.dateDiff(lastUpdated.toDate(), now.toDate(), user.timezone)

                  // If there hasn't been any activity for 10+ minutes and the user is 'driving'
                  // then de-activate the user 'activity'.
                  if ((diff.asMinutes() > 10) && isDriving) {
                    const activityDataList: any[] = activityData.data

                    // Only keey activity data if:
                    //   1. The activity data is not null
                    //   2. The activity list has more than 1 entry
                    //   3. The activity data has an overall distance >400 meters
                    if ((activityDataList !== null) && (activityDataList.length > 1) && userUtils.hasMovedDistance(activityDataList, 400)) {
                      const nowFs: admin.firestore.FieldValue = admin.firestore.FieldValue.serverTimestamp()
                      activityData.end_time = nowFs
                      activityData.last_updated = nowFs
                      activityData.active = false
                      if (activityData.meta === null) {
                        activityData.meta = {}
                      }

                      activityData.meta['distance'] = userUtils.calculateActivityDistance(activityDataList)

                      // Updates the firestore user 'activity' document
                      plist.push(activityDoc.ref.set(activityData, { merge: true }))
                    } else {
                      plist.push(activityDoc.ref.delete())
                    }

                    updateUser(plist, userDoc, user)
                  }
                } else {
                  updateUser(plist, userDoc, user)
                }
              })
            }

            return Promise.all(plist)
          })
          .catch((error: any) => {
            console.error(error)
            return Promise.resolve(null)
          }))
      })

      try {
        await Promise.all(promises)
        return await Promise.resolve('ok')
      } catch (error) {
        console.error(error)
        return Promise.resolve('error')
      }
    } catch (error) {
      console.error(error)
      return Promise.resolve('error')
    }
  })

function updateUser(promises: Array<Promise<any>>, userDoc: FirebaseFirestore.QueryDocumentSnapshot, user: any): void {
  if (user && user.location && user.location.activity && (user.location.activity.type !== userUtils.UserActivityType.STILL)) {
    user.location.activity.type = userUtils.UserActivityType.STILL
    user.last_updated = admin.firestore.FieldValue.serverTimestamp()

    // Updates the firestore user document
    promises.push(userDoc.ref.set(user, { merge: true }))
  }
}
