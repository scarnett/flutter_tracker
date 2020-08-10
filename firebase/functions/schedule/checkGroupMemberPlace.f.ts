import * as admin from 'firebase-admin'
import * as functions from 'firebase-functions'
import * as userUtils from '../utils/user-utils'
import * as groupUtils from '../utils/group-utils'
import * as placeUtils from '../utils/place-utils'
import * as messageUtils from '../utils/message-utils'

/**
 * This checks for users 'place' and determines whether they're still within its geofence.
 * 
 * Sometimes the geofence listener in the app doesn't report entering or leaving events 
 * so this helps out by checking in on things and performing some cleanup if it needs to.
 */
exports = module.exports = functions.pubsub
  .schedule('every 10 minutes')
  .timeZone('America/New_York')
  .onRun(async (context: functions.EventContext) => {
    console.log('Checking group member place data...')

    try {
      const groupSnapshot = await admin.firestore()
        .collection('groups')
        .get()

      const promises: Array<Promise<any>> = []

      groupSnapshot.docs.forEach((groupDoc: FirebaseFirestore.QueryDocumentSnapshot) => {
        const members: any = groupDoc.get('members')
        if (members) {
          Object.keys(members).map((uid) => {
            if (groupDoc.get('member_index').includes(uid)) {
              const member: any = members[uid]
              if (member.place && (member.place.documentId !== null)) {
                promises.push(placeUtils.getPlace(member.place.documentId).get()
                  .then(async (placeDoc: FirebaseFirestore.DocumentSnapshot) => {
                    const placeData: FirebaseFirestore.DocumentData | undefined = placeDoc.data()

                    // If the user isn't within the place geofence then wipe out the place data
                    const withinRadius: boolean = userUtils.isUserWithinPlaceRadius(member, placeData)
                    if (withinRadius) {
                      if (placeData && !placeData.active) {
                        promises.push(placeUtils.activatePlace(placeDoc.ref))
                      }
                    } else {
                      const groupMemberData: any = {}
                      groupMemberData[uid] = {
                        'place': null
                      }

                      // Adds a geofence activity document to the user
                      promises.push(messageUtils.addGeofenceActivity(uid, member, placeData, userUtils.UserActivityType.GEOFENCE_LEAVING))

                      try {
                        // Updates the 'place' in the users' groups
                        await groupUtils.syncMemberGroups(uid, groupMemberData)
                        return await placeUtils.checkPlaceGeofences(uid, member, groupDoc.id)
                      } catch (error) {
                        console.error(error)
                        return Promise.resolve(null)
                      }
                    }

                    return Promise.resolve(null)
                  })
                  .catch((error: any) => {
                    console.error(error)
                    return Promise.resolve(null)
                  }))
              } else if (!member.place) {
                // If the user doesn't have any 'place' data then check to see if the user
                // if within any of the existing place geofences.
                promises.push(placeUtils.checkPlaceGeofences(uid, member, groupDoc.id))
              }
            }
          })
        }
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
