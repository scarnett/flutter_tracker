import * as admin from 'firebase-admin'
import * as httpUtils from '../utils/http-utils'
import * as userUtils from '../utils/user-utils'
import * as geofenceUtils from '../utils/geofence-utils'
import * as groupUtils from '../utils/group-utils'
import * as placeUtils from '../utils/place-utils'
import * as messageUtils from '../utils/message-utils'

/**
 * This endpoint is used to send messages from the user devices
 */
exports.send_message = httpUtils.appEndpoints.post('/message', (req: any, res: any): any => {
  return userUtils.getUserByAuthToken(req)
    .then((userSnap: FirebaseFirestore.QuerySnapshot) => {
      const params: any = req.query
      const promises: Array<Promise<any>> = []

      userSnap.forEach((fromUserDoc: FirebaseFirestore.QueryDocumentSnapshot) => {
        const fromUser: any = fromUserDoc.data()
        if (fromUser && fromUser.location && fromUser.location.activity) {
          const activityType: string = fromUser.location.activity.type
          // console.log(activityType, params.type)
          // const isMoving: boolean = userUtils.isMoving(activityType)
          // const isDriving: boolean = userUtils.isDriving(activityType)

          switch (params.type) {
            case 'ENTERING_GEOFENCE':
              promises.push(handleGeofenceEvent(placeUtils.PlaceEventType.ENTERING, activityType, fromUserDoc.id, fromUser, req, params))
              break

            case 'LEAVING_GEOFENCE':
              promises.push(handleGeofenceEvent(placeUtils.PlaceEventType.LEAVING, activityType, fromUserDoc.id, fromUser, req, params))
              break

            default:
              break
          }
        }
      })

      if (promises.length) {
        return Promise.all(promises)
          .then(() => res.status(200).send('ok'))
          .catch((error: any) => {
            console.error(error)
            return res.status(401).send('error')
          })
      }

      return res.status(200).send('ok')
    })
    .catch((err: any) => {
      console.log(err)
      return res.status(401).send('error')
    })
})

/**
 * @param eventType 'entering' or 'leaving'
 * @param activityType 'still', 'on_foot', 'walking', 'running', 'in_vehicle', 'on_bicycle'
 * @param user the user that triggered the geofence event
 * @param req the http request data
 * @param params the http request params
 */
function handleGeofenceEvent(eventType: string, activityType: string, fromUid: string, user: any, req: any, params: any) {
  const meta: any = req.body
  if (meta === null) {
    return Promise.reject('bad geofence data')
  }

  const identifier: string = meta.identifier
  const placeRef: any = admin.firestore()
    .collection('places')
    .doc(identifier)

  // Get the place
  return placeRef.get()
    .then((placeDoc: FirebaseFirestore.QueryDocumentSnapshot) => {
      const promises: Array<Promise<any>> = []
      const now: any = admin.firestore.FieldValue.serverTimestamp()
      const placeData: FirebaseFirestore.DocumentData = placeDoc.data()
      const groupMemberData: any = {}

      switch (eventType) {
        case placeUtils.PlaceEventType.ENTERING:
          if (placeData && placeData.details.position && (placeData.details.position.length === 2)) {
            // Here we're just making sure that the users' current location is
            // actually within the geofence that's set in the place record.
            // Sometimes the app will report sporadic false readings that may
            // fall within a geofence that the user isn't actually in so we try
            // to filter those out using the logic below.
            const withinRadius: boolean = userUtils.isUserWithinPlaceRadius(user, placeData)
            if (withinRadius) {
              groupMemberData[fromUid] = {
                'place': {
                  'documentId': placeDoc.id,
                  'name': placeData.name || 'unknown',
                  'last_updated': now
                }
              }

              // Adds a geofence activity document to the user
              promises.push(messageUtils.addGeofenceActivity(fromUid, user, placeData, userUtils.UserActivityType.GEOFENCE_ENTERING))

              if (!placeData.active) {
                promises.push(placeUtils.activatePlace(placeDoc.ref))
              }
            } else {
              groupMemberData[fromUid] = {
                'place': null
              }

              if (placeData.active) {
                promises.push(placeUtils.deactivatePlaceByGroupId(placeDoc, user.active_group))
              }
            }
          }

          break

        case placeUtils.PlaceEventType.LEAVING:
        default:
          groupMemberData[fromUid] = {
            'place': null
          }

          // Adds a geofence activity document to the user
          promises.push(messageUtils.addGeofenceActivity(fromUid, user, placeData, userUtils.UserActivityType.GEOFENCE_LEAVING))

          if (placeData.active) {
            promises.push(placeUtils.deactivatePlaceByGroupId(placeDoc, user.active_group))
          }

          break
      }

      // Updates the 'place' in the users' groups
      promises.push(groupUtils.syncMemberGroups(fromUid, groupMemberData))

      // Create the messages and send them
      if (placeData) {
        const messages: any[] = geofenceUtils.buildGeofenceNotifications(
          fromUid,
          user.active_group,
          params.type,
          eventType,
          meta,
          placeData
        )

        if (messages.length) {
          messages.forEach((message) => promises.push(admin.firestore().collection('messages').add(message)))
        }
      }

      return Promise.all(promises)
        .then(() => {
          /*
          const userActivityRef: FirebaseFirestore.Query = userUtils.getActiveActivity(fromUid)
          */

          return placeUtils.addPlaceActivity(identifier, {
            'type': eventType,
            'user': userUtils.tagUser(fromUid, user),
            'activity_id': null, // TODO!
            'created': now
          })
        })
        .catch((error: any) => {
          console.error(error)
          return Promise.resolve(null)
        })
    })
    .catch((error: any) => {
      console.error(error) // TODO send this somewhere
      return Promise.reject('geofence error')
    })
}
