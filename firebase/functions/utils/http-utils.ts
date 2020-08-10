import { google } from 'googleapis'
import express from 'express'
import * as fs from 'fs'

const rp = require('request-promise')
const PROJECT_ID = 'flutter-tracker'
const RC_HOST = 'firebaseremoteconfig.googleapis.com'
const RC_URL = `https://${RC_HOST}/v1/projects/${PROJECT_ID}/remoteConfig`
const RC_SCOPES = [
  'https://www.googleapis.com/auth/firebase.remoteconfig',
  'https://www.googleapis.com/auth/userinfo.email',
  'https://www.googleapis.com/auth/firebase.database',
  'https://www.googleapis.com/auth/androidpublisher'
]

export const appEndpoints = express()

export async function getRemoteConfig() {
  return getAccessToken()
    .then((accessToken) => {
      const options = {
        uri: RC_URL,
        headers: {
          'Authorization': `Bearer ${accessToken}`
        },
        json: true
      }

      return rp(options)
        .then((config: any) => Promise.resolve(config))
        .catch((err: any) => Promise.resolve(null))
    })
    .catch((error: any) => {
      console.error(error)
      return Promise.resolve(null)
    })
}

export function getRemoteConfigValue(config: any, key: string) {
  if (config === null) {
    return null
  }

  if ('parameters' in config) {
    return config.parameters[key].defaultValue.value // Firebase RC format
  }

  return config[key] // Cached RC format
}

export function getAccessToken() {
  return new Promise((resolve, reject) => {
    const key: any = require('../keys/flutter_tracker-firebase-adminsdk.json')
    const jwtClient: any = new google.auth.JWT(key.client_email, undefined, key.private_key, RC_SCOPES, undefined)
    jwtClient.authorize((err: any, tokens: any) => {
      if (err) {
        reject(err)
        return
      }

      resolve(tokens.access_token)
    })
  })
}

/**
 * Retrieve the current Firebase Remote Config template from the server. Once
 * retrieved the template is stored locally in a file named `config.json`.
 */
export async function cacheRemoteConfigTemplate(fileName: string = 'config.json') {
  try {
    const config = await getRemoteConfig()
    fs.writeFileSync(fileName, config)
  } catch (error) {
    console.error(error)
  }
}
