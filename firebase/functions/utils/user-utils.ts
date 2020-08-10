import * as admin from 'firebase-admin'
import * as geolib from 'geolib'
import * as dateUtils from '../utils/date-utils'
import moment = require('moment')
// import * as httpUtils from './http-utils'

// const rp = require('request-promise')

export function getUser(uid: string): Promise<FirebaseFirestore.DocumentSnapshot | null> {
  if (uid) {
    return admin.firestore()
      .collection('users')
      .doc(uid)
      .get()
  }

  return Promise.resolve(null)
}

export function getActiveActivity(uid: string): FirebaseFirestore.Query {
  return getActiveActivityFromDoc(
    admin.firestore()
      .collection('users')
      .doc(uid)
  )
}

export function getActiveActivityFromDoc(doc: FirebaseFirestore.DocumentReference): FirebaseFirestore.Query {
  return doc
    .collection('activity')
    .where('active', '==', true)
}

export function getUserByAuthToken(req: any): Promise<FirebaseFirestore.QuerySnapshot> {
  let authToken: string
  const authHeader: string = req.get('Authorization')
  if (authHeader && authHeader.startsWith('Bearer ')) {
    const authHeaderParts: string[] = authHeader.split(' ')
    if (authHeaderParts.length === 2) {
      authToken = authHeaderParts[1]

      const userRef: FirebaseFirestore.Query = admin.firestore()
        .collection('users')
        .where('auth.token', '==', authToken)

      if (userRef) {
        return userRef.get()
      }

      return Promise.reject(`User not found: ${authHeader}`)
    }
  }

  return Promise.reject(`Bad auth header: ${authHeader}`)
}

export enum UserActivityType {
  STILL = 'still',
  ON_FOOT = 'on_foot',
  WALKING = 'walking',
  RUNNING = 'running',
  IN_VEHICLE = 'in_vehicle',
  ON_BICYCLE = 'on_bicycle',
  CHECKIN_SENDER = 'checkin_sender',
  CHECKIN_RECEIVER = 'checkin_receiver',
  DRIVING_STARTED = 'driving_started',
  DRIVING_STOPPED = 'driving_stopped',
  GEOFENCE_ENTERING = 'geofence_entering',
  GEOFENCE_LEAVING = 'geofence_leaving'
}

export function isMoving(activityType: string | null): boolean {
  if (activityType === null) {
    return false
  }

  switch (activityType) {
    case UserActivityType.STILL:
    case UserActivityType.CHECKIN_SENDER:
    case UserActivityType.CHECKIN_RECEIVER:
      return false

    case UserActivityType.ON_FOOT:
    case UserActivityType.WALKING:
    case UserActivityType.RUNNING:
    case UserActivityType.IN_VEHICLE:
    case UserActivityType.ON_BICYCLE:
    case UserActivityType.GEOFENCE_ENTERING:
    case UserActivityType.GEOFENCE_LEAVING:
    default:
      return true
  }
}

export function isDriving(activityType: string | null): boolean {
  if (activityType === null) {
    return false
  }

  switch (activityType) {
    case UserActivityType.STILL:
    case UserActivityType.ON_FOOT:
    case UserActivityType.WALKING:
    case UserActivityType.RUNNING:
    case UserActivityType.ON_BICYCLE:
    case UserActivityType.CHECKIN_SENDER:
    case UserActivityType.CHECKIN_RECEIVER:
    case UserActivityType.GEOFENCE_ENTERING:
    case UserActivityType.GEOFENCE_LEAVING:
      return false

    case UserActivityType.IN_VEHICLE:
    default:
      return true
  }
}

// This works but it's being handled in the app at the moment
/*
export function syncNearByLocations(userDoc: any, nearBy: any, config: any): Promise<any> {
  if (userDoc) {
    const user: any = userDoc.data()
    const coords: any = user.location.coords
    let distance: number = -1

    if (nearBy && nearBy.last_position) {
      distance = geolib.getPreciseDistance(
        { latitude: user.location.coords.latitude, longitude: coords.longitude }, // Current map position
        { latitude: nearBy.last_position.latitude, longitude: nearBy.last_position.longitude }  // Last recorded map position
      )
    }

    const nearbyDistanceUpdate: number = httpUtils.getRemoteConfigValue(config, 'nearby_distance_update')
    if ((distance < 0) || (distance > nearbyDistanceUpdate)) {
      const exploreUrl: string = httpUtils.getRemoteConfigValue(config, 'places_explore_nearby_url')
      const appId: string = httpUtils.getRemoteConfigValue(config, 'places_api_id')
      const appCode: string = httpUtils.getRemoteConfigValue(config, 'places_app_code')
      const placesUrl: string = `${exploreUrl}` +
        `?in=${coords.latitude},${coords.longitude};r=${nearbyDistanceUpdate}` +
        '&tf=plain' +
        `&app_id=${appId}` +
        `&app_code=${appCode}`

      const options = {
        uri: placesUrl,
        json: true
      }

      return rp(options).then((response: any) => {
        const places: any[] = []

        // @see https://developer.here.com/api-explorer/rest/places/explore-nearby-places
        if (response.results.items) {
          response.results.items.forEach((place: any) => places.push(place))
        }

        return userDoc.ref.set({
          'near_by': {
            'last_updated': admin.firestore.FieldValue.serverTimestamp(),
            'last_position': coords,
            'places': places
          }
        }, { merge: true })
      }).catch((err: any) => Promise.resolve(null))
    }
  }

  return Promise.resolve('ok')
}
*/

export function syncActivity(userId: string, beforeUser: any, afterUser: any): Promise<any> {
  const promises: Array<Promise<any>> = []
  const hasBeforeLocation: boolean = (beforeUser && beforeUser.location)
  const hasAfterLocation: boolean = (afterUser && afterUser.location)
  if (hasAfterLocation) {
    let beforeActivityType: string | null = null
    let isDrivingBefore: boolean = false

    if (hasBeforeLocation) {
      beforeActivityType = (!beforeUser.location || !beforeUser.location.activity) ? null : beforeUser.location.activity.type
      isDrivingBefore = isDriving(beforeActivityType)
    }

    const afterActivityType: string = (!afterUser.location || !afterUser.location.activity) ? null : afterUser.location.activity.type
    const isDrivingAfter: boolean = isDriving(afterActivityType)
    if (!isDrivingBefore && isDrivingAfter) {
      const now: any = admin.firestore.FieldValue.serverTimestamp()

      // Create new 'activity' doc and activate it
      promises.push(admin.firestore()
        .collection('users')
        .doc(userId)
        .collection('activity')
        .add({
          'active': true,
          'type': UserActivityType.IN_VEHICLE,
          'start_time': now,
          'last_updated': now,
          'data': [{
            'battery': afterUser.battery,
            'location': afterUser.location
          }],
          'meta': null,
          'events': {
            0: {
              'type': UserActivityType.DRIVING_STARTED,
              'created': now,
              'data': {
                'from': tagUser(userId, afterUser)
              }
            }
          }
        }))
    } else if (isDrivingBefore && isDrivingAfter) {
      // Update the active 'activity' doc
      const activityRef: FirebaseFirestore.Query = getActiveActivity(userId)
      promises.push(activityRef.get().then((activitySnapshot: FirebaseFirestore.QuerySnapshot) => {
        if (activitySnapshot.docs.length > 0) {
          const activityDoc: FirebaseFirestore.QueryDocumentSnapshot = activitySnapshot.docs[0]
          const activityData: any = activityDoc.data()
          activityData['last_updated'] = admin.firestore.FieldValue.serverTimestamp()
          activityData['data'].push({
            'battery': afterUser.battery,
            'location': afterUser.location
          })

          return activityDoc.ref.set(activityData, { merge: true })
        }

        return Promise.resolve(null)
      }))
    } else if (isDrivingBefore && !isDrivingAfter) {
      // Deactivate the active 'activity'
      const activityRef: FirebaseFirestore.Query = getActiveActivity(userId)
      promises.push(activityRef.get().then((activitySnapshot: FirebaseFirestore.QuerySnapshot) => {
        if (activitySnapshot.docs.length > 0) {
          const activityDoc: FirebaseFirestore.QueryDocumentSnapshot = activitySnapshot.docs[0]
          const activityData: FirebaseFirestore.DocumentData = activityDoc.data()
          const dataList: FirebaseFirestore.DocumentData[] = activityData['data']
          if ((dataList !== null) && (dataList.length > 1)) {
            // Only keep activity data with an overall distance >400 meters
            // @see ../schedule/checkStaleUserActivity.f.ts
            if (hasMovedDistance(dataList, 400)) {
              const now: FirebaseFirestore.FieldValue = admin.firestore.FieldValue.serverTimestamp()
              activityData['end_time'] = now
              activityData['last_updated'] = now
              activityData['active'] = false
              activityData['meta'] = {
                'distance': calculateActivityDistance(dataList)
              }

              const currentEvents: any = activityData['events']
              const nextId: number = (Object.keys(currentEvents).length + 1)
              activityData['events'][nextId] = {
                'type': UserActivityType.DRIVING_STOPPED,
                'created': now,
                'data': {
                  'from': tagUser(userId, afterUser)
                }
              }

              return activityDoc.ref.set(activityData, { merge: true })
            }
          }

          // If only one data point is in this document then delete the document
          return activityDoc.ref.delete()
        }

        return Promise.resolve(null)
      }))
    }
  }

  return Promise.all(promises)
}

export function calculateActivityDistance(data: any[]): number {
  let distance: number = 0

  if ((data !== null) && (data.length > 1)) {
    const count: number = data.length
    const firstEntry: any = data[0]
    const lastEntry: any = data[count - 1]

    if (lastEntry.location.odometer && firstEntry.location.odometer &&
      (lastEntry.location.odometer !== firstEntry.location.odometer)) {
      // Calculates the distance in meters from the odometer values
      // Using the odometer values to calculate the distance will give the most accurate distance traveled.
      distance = (lastEntry.location.odometer - firstEntry.location.odometer)
      if (distance > 0) {
        return distance
      }
    }

    if (firstEntry.location.coords &&
      ('latitude' in firstEntry.location.coords) &&
      ('longitude' in firstEntry.location.coords) &&
      lastEntry.location.coords &&
      ('latitude' in lastEntry.location.coords) &&
      ('longitude' in lastEntry.location.coords)) {
      // Calculates the distance in meters from the point coordinates
      // Using the point coordinates will give a less accurate distance traveled.
      // Hopefully we do not make it this far.
      distance = calculateDistance([
        lastEntry.location.coords.latitude,
        lastEntry.location.coords.longitude
      ], [
        firstEntry.location.coords.latitude,
        firstEntry.location.coords.longitude
      ])

      if (distance > 0) {
        return distance
      }
    }
  }

  return distance
}

export function calculateDistance(coords1: number[], coords2: number[]): number {
  if (coords1 && (coords1.length === 2) && coords2 && (coords2.length === 2)) {
    const calculatedDistance: number = geolib.getPreciseDistance(
      { latitude: coords1[0], longitude: coords1[1] },
      { latitude: coords2[0], longitude: coords2[1] },
    )

    return calculatedDistance
  }

  return 0
}

export function calculateUserDistance(user: any, place: any): number {
  if (user && user.location.coords &&
    ('latitude' in user.location.coords) && ('longitude' in user.location.coords) &&
    place && place.details.position && (place.details.position.length === 2)) {
    return calculateDistance([
      place.details.position[0],
      place.details.position[1]
    ], [
      user.location.coords.latitude,
      user.location.coords.longitude
    ])
  }

  return 0
}

export function hasMovedDistance(data: any[], minDistance: number): boolean {
  const distance: number = calculateActivityDistance(data)
  if (distance >= minDistance) {
    return true
  }

  return false
}

export function isUserWithinPlaceRadius(user: any, place: any): boolean {
  if (user && place) {
    return geolib.isPointWithinRadius(
      { latitude: place.details.position[0], longitude: place.details.position[1] },
      { latitude: user.location.coords.latitude, longitude: user.location.coords.longitude },
      place.distance
    )
  }

  return false
}

export function makeDeletedEmailAddress(email: string): string {
  if (email) {
    const emailParts: string[] = email.split('@')
    const newEmail: string = `${emailParts[0]}+deleted@${emailParts[1]}`
    return newEmail
  }

  return ''
}

/**
 * This updates the user provider to offline status if the user record hasn't been updated in over an hour
 * @param user 
 */
export function checkLastLocationTimestamp(user: any): boolean {
  if ((user !== null) && (user.timezone !== null) && (user.last_updated !== null)) {
    const now: moment.Moment = moment(Date.now())
    const lastUpdated: moment.Moment = moment(user.last_updated.toDate()).tz(user.timezone)
    const diff: moment.Duration = dateUtils.dateDiff(lastUpdated.toDate(), now.toDate(), user.timezone)
    const minDiff: number = diff.asMinutes()
    if ((minDiff > 60) && ((user.provider === null) || user.provider.enabled)) {
      // user.last_updated = admin.firestore.FieldValue.serverTimestamp()
      user.provider = {
        enabled: false
        // gps: false,
        // network: false,
        // status: 0
      }

      return true
    } else if ((minDiff <= 60) && (user.provider === null) || !user.provider.enabled) {
      user.last_updated = admin.firestore.FieldValue.serverTimestamp()
      user.provider = {
        enabled: true
        // gps: true,
        // network: true,
        // status: 3
      }

      return true
    }
  }

  return false
}

export function tagUser(uid: string, user: any) {
  return {
    'uid': uid,
    'name': user.name,
    'image_url': (user.image && ('secure_url' in user.image)) ? user.image.secure_url : null,
    'location': user.location
  }
}