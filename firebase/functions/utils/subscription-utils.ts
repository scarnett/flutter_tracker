import * as admin from 'firebase-admin'

export function buildAccountSubscribeNotification(uid: string): any[] {
  const messages: any[] = []
  const message: any = {
    'toUid': uid,
    'type': 'ACCOUNT_SUBSCRIBED',
    'meta': {
      'data': {
        'icon': 'sentiment_satisfied'
      }
    },
    'created': admin.firestore.FieldValue.serverTimestamp()
  }

  messages.push(message)
  return messages
}

export function buildAccountSubscriptionUpdateNotification(uid: string): any[] {
  const messages: any[] = []
  const message: any = {
    'toUid': uid,
    'type': 'ACCOUNT_SUBSCRIPTION_UPDATED',
    'meta': {
      'data': {
        'icon': 'sentiment_satisfied'
      }
    },
    'created': admin.firestore.FieldValue.serverTimestamp()
  }

  messages.push(message)
  return messages
}

export function buildAccountUnsubscribeNotification(uid: string): any[] {
  const messages: any[] = []
  const message: any = {
    'toUid': uid,
    'type': 'ACCOUNT_UNSUBSCRIBED',
    'meta': {
      'data': {
        'icon': 'sentiment_neutral'
      }
    },
    'created': admin.firestore.FieldValue.serverTimestamp()
  }

  messages.push(message)
  return messages
}
