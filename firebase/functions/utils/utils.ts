import * as admin from 'firebase-admin'
import * as messageUtils from './message-utils'
import * as messageModel from '../models/message'

const fillTemplate = require('es6-dynamic-template')

export function template(str: string, context: any): any {
  const helpers: any = {
    if: (condition: boolean, thenTemplate: string, elseTemplate = '') => {
      return condition ? thenTemplate : elseTemplate
    },
    unless: (condition: boolean, thenTemplate: string, elseTemplate: string) => {
      return !condition ? thenTemplate : elseTemplate
    },
    registerHelper: (name: any, fn: any) => {
      helpers[name] = fn
    }
  }

  // -------------------------------------------------------- Register the Uppercase Helper
  helpers.registerHelper('uppercase', (_str: string): string => {
    return _str.toUpperCase()
  })

  // -------------------------------------------------------- Register the Capitalize Helper
  helpers.registerHelper('capitalize', (_str: string): string => {
    return _str[0].toUpperCase() + str.slice(1)
  })

  context['helpers'] = helpers
  return fillTemplate(str, context)
}

// ---------------------------------------------------------- Pushes a message to a device
export async function pushMessage(messageDoc: any, toUser: any, messageData: messageModel.Message | null): Promise<string | null> {
  if (messageData === null) {
    return Promise.resolve(null)
  }

  const promises: Array<Promise<any>> = []

  const msg = {
    android: {
      notification: {
        title: messageData.title,
        body: messageData.body,
        color: messageData.color,
        sound: messageData.sound,
        // image: messageData.image
      }
    },
    data: {
      ...messageData.data,
      'send_date': Date.now().toString(),
      'click_action': 'FLUTTER_NOTIFICATION_CLICK'
    },
    token: toUser['fcm']['token']
  }

  // Save the message data into the document
  promises.push(messageDoc.ref.set({ 'meta': msg }, { merge: true }))

  // Send push notification
  promises.push(admin.messaging().send(msg))

  try {
    await Promise.all(promises)
    return await Promise.resolve('ok')
  } catch (error) {
    console.error(error)
    return Promise.resolve('cancel')
  }
}

// ---------------------------------------------------------- Parses the data and builds a message based off of the type
export function parseData(data: any, fromUser: any, toUser: any, extraData: any = {}): messageModel.Message | null {
  if (data && ('type' in data)) {
    const message: messageModel.Message = new messageModel.Message()
    message.data = {
      type: data['type'],
      groupId: data['groupId'],
      fromUid: data['fromUid'],
      toUid: data['toUid']
    }

    if (fromUser !== null) {
      message.data['fromUserName'] = fromUser['name']

      const fromUserImage: any = fromUser['image']
      if (fromUserImage) {
        message.image = cloudinaryTransformUrl(fromUserImage.secure_url, 'push_notification_avatar')
        message.data['fromUserImage'] = cloudinaryTransformUrl(fromUserImage.secure_url)
      }
    }

    const toUserImage: any = toUser['image']
    if (toUserImage) {
      message.data['toUserImage'] = cloudinaryTransformUrl(toUserImage.secure_url)
    }

    if ((data !== null) &&
      ('meta' in data) &&
      ('data' in data['meta']) &&
      ('icon' in data['meta']['data'])) {
      message.data['icon'] = data['meta']['data']['icon']
    }

    let context: any

    if (fromUser === null) {
      context = Object.assign({}, {
        'toName': toUser['name']
      }, extraData)
    } else {
      context = Object.assign({}, {
        'fromName': fromUser['name'],
        'toName': toUser['name']
      }, extraData)
    }

    switch (data['type']) {
      case messageUtils.MessageType.CHECKIN:
        message.title = template('Hey ${toName}!', context)
        message.body = template('${fromName} just checked in!', context)
        break

      case messageUtils.MessageType.JOIN_GROUP:
        message.title = template('Hey ${toName}!', context)
        message.body = template('${fromName} joined your group!', context)
        break

      case messageUtils.MessageType.LEAVE_GROUP:
        message.title = template('Hey ${toName}!', context)
        message.body = template('${fromName} left your group!', context)
        break

      case messageUtils.MessageType.ENTERING_GEOFENCE:
        message.title = template('Hey ${toName}!', context)
        message.body = template('${fromName} has arrived at ${placeName}', context)
        break

      case messageUtils.MessageType.LEAVING_GEOFENCE:
        message.title = template('Hey ${toName}!', context)
        message.body = template('${fromName} left ${placeName}', context)
        break

      case messageUtils.MessageType.ACCOUNT_SUBSCRIBED:
        message.title = template('Hey ${toName}!', context)
        message.body = template('You account was upgraded successfully!', context)
        break

      case messageUtils.MessageType.ACCOUNT_SUBSCRIPTION_UPDATED:
        message.title = template('Hey ${toName}!', context)
        message.body = template('You account subscription was updated successfully!', context)
        break

      case messageUtils.MessageType.ACCOUNT_UNSUBSCRIBED:
        message.title = template('Hey ${toName}!', context)
        message.body = template('Your were successfully unsubscribed.', context)
        break
    }

    return message
  }

  return null
}

export function cloudinaryTransformUrl(url: string, transformation: string = 'avatar', extraOptions: any = []): string | null {
  if (url === null) {
    return null
  }

  if (hasAlreadyBeenTransformed(url)) {
    return url
  }

  const urlParts: string[] = url.split('upload/')
  let options: string = ''

  if (extraOptions && (extraOptions.length > 0)) {
    for (const option in extraOptions) {
      options += `,${option}`
    }
  }

  // Adds the cloudinary 'transformation' to the url
  const transformedUrl: string = `${urlParts[0]}upload/t_${transformation}${options}/${urlParts[1]}`
  return transformedUrl
}

function hasAlreadyBeenTransformed(url: string): boolean {
  if (url === null) {
    return false
  }

  if (url.indexOf('upload/t_') >= 0) {
    return true
  }

  return false
}
