import * as admin from 'firebase-admin'

export function buildGeofenceNotifications(fromUid: string, groupId: string, geofenceType: string, eventType: string, messageData: any, placeData: any): any[] {
  const messages: any[] = []
  const notificationUsers: any[] = getNotificationUsers(fromUid, placeData)
  if (notificationUsers && (notificationUsers.length > 0)) {
    notificationUsers.forEach((user) => {
      const toUid: string = Object.keys(user)[0]
      const fromUserData: any = user[toUid]
      const fromUserSettings: any = fromUserData[fromUid]
      if (fromUserSettings && fromUserSettings.hasOwnProperty(eventType) && fromUserSettings[eventType]) {
        messageData['extraData'] = {
          'placeName': placeData.name
        }

        const message: any = {
          'fromUid': fromUid,
          'toUid': toUid,
          'groupId': groupId,
          'type': geofenceType,
          'created': admin.firestore.FieldValue.serverTimestamp(),
          'meta': messageData
        }

        messages.push(message)
      }
    })
  }

  return messages
}

export function getNotificationUsers(fromUid: string, placeData: any): any[] {
  const users: any[] = []

  // Make sure notifcations are enabled and that we have some notification settings
  if (placeData && (placeData.notifications !== null) && (Object.keys(placeData.notifications).length > 0)) {
    // Iterate the notification users
    const notificationKeys = Object.keys(placeData.notifications).filter(uid => (uid !== fromUid))
    for (const toUid of notificationKeys) {
      const userData: any = {}
      userData[toUid] = filterNotificationUserSettings([fromUid], placeData.notifications[toUid])
      users.push(userData)
    }
  }

  return users
}

export function filterNotificationUserSettings(allowedUids: string[], data: any): any {
  if (!allowedUids || (allowedUids.length === 0) || !data) {
    return {}
  }

  const filtered: any = Object.keys(data)
    .filter(key => allowedUids.includes(key))
    .reduce((obj: any, key: any) => {
      obj[key] = data[key]
      return obj
    }, {})

  return filtered
}
