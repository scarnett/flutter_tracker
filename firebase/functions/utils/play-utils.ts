import { google } from 'googleapis'

const rp = require('request-promise')
const PACKAGE_NAME = 'io.flutter_tracker.app.dev' // TODO!
const PLAY_HOST = 'www.googleapis.com'
const PLAY_URL = `https://${PLAY_HOST}/androidpublisher/v3/applications/${PACKAGE_NAME}/purchases/subscriptions/`
const PLAY_SCOPES = [
  'https://www.googleapis.com/auth/androidpublisher'
]

// @see https://developers.google.com/android-publisher/api-ref/purchases/subscriptions/cancel
export async function unsubscribe(subscriptionId: string, purchaseToken: string) {
  return getAccessToken().then((accessToken) => {
    const url: string = `${PLAY_URL}${subscriptionId}/tokens/${purchaseToken}:cancel`
    const options = {
      uri: url,
      headers: {
        'Authorization': `Bearer ${accessToken}`
      },
      method: 'POST',
      json: true
    }

    return rp(options)
      .then((res: any) => Promise.resolve(res))
      .catch((error: any) => {
        console.error(error)
        return Promise.resolve(null)
      })
  })
}

export function getAccessToken() {
  return new Promise((resolve, reject) => {
    const key: any = require('../keys/flutter_tracker-play-api.json')
    const jwtClient: any = new google.auth.JWT(key.client_email, undefined, key.private_key, PLAY_SCOPES, undefined)
    jwtClient.authorize((err: any, tokens: any) => {
      if (err) {
        reject(err)
        return
      }

      resolve(tokens.access_token)
    })
  })
}
