import * as admin from 'firebase-admin'
import * as functions from 'firebase-functions'
import * as httpUtils from '../../utils/http-utils'
import * as userUtils from '../../utils/user-utils'
import * as groupUtils from '../../utils/group-utils'
import * as subscriptionUtils from '../../utils/subscription-utils'

/**
 * This observes the users being updated in the system.
 */
exports = module.exports = functions.firestore
  .document('users/{userId}').onUpdate(async (change: any, context: any) => {
    const beforeUser: any = change.before.data()
    const afterUser: any = change.after.data()
    if (afterUser) {
      const promises: Array<Promise<any>> = []

      checkPurchase(promises, context, beforeUser, afterUser)

      if (!beforeUser.last_updated.isEqual(afterUser.last_updated)) {
        // Try to load the cached config first
        const config: any = require('../../flutter_tracker-firebase-config.json')
        if (config) {
          return syncData(promises, change, context, beforeUser, afterUser, config)
        }

        try {
          const _config = await httpUtils.getRemoteConfig()
          return await syncData(promises, change, context, beforeUser, afterUser, _config)
        } catch (error) {
          console.error(error)
          return Promise.resolve(null)
        }
      }

      try {
        await Promise.all(promises)
        return await Promise.resolve(null)
      } catch (error) {
        console.error(error)
        return Promise.resolve(null)
      }
    }

    return Promise.resolve(null)
  })

async function syncData(
  promises: Promise<any>[],
  change: any,
  context: any,
  beforeUser: any,
  afterUser: any,
  config: any
): Promise<string> {
  const now: any = admin.firestore.FieldValue.serverTimestamp()
  const userId: any = context.params.userId

  // Check if the user is being deleted
  const isBeingDeleted: boolean = (afterUser && afterUser.deleted)
  if (isBeingDeleted) {
    const emailAddress: string = userUtils.makeDeletedEmailAddress(afterUser.email)

    // Updates the firestore user record
    promises.push(change.after.ref.set({
      'email': emailAddress
    }, { merge: true }))

    // Updates the firebase auth record
    promises.push(admin.auth().updateUser(userId, {
      'email': emailAddress,
      'disabled': true
    }))

    try {
      await Promise.all(promises)

      try {
        await groupUtils.deleteMemberFromGroups(userId)
        return await Promise.resolve('ok')
      } catch (error) {
        console.error(error)
        return Promise.resolve('error')
      }
    } catch (error) {
      console.error(error)
      return Promise.resolve('error')
    }
  }

  // Syncs the user activity
  promises.push(userUtils.syncActivity(userId, beforeUser, afterUser))

  // const hasAfterLocation: boolean = (afterUser && afterUser.location)
  const userData: any = {}

  /*
  if (afterUser.near_by) {
    userData['near_by'] = afterUser.near_by
  } else if (hasAfterLocation && afterUser.location.coords) {
    userData['near_by'] = {
      last_updated: now,
      last_position: afterUser.location.coords
    }
  }
  */

  if (!afterUser.auth) {
    const authToken = admin.auth().createCustomToken(userId)
    userData['auth'] = {
      'token': authToken
    }
  }

  if (Object.keys(userData).length > 0) {
    // Updates the firestore user record
    promises.push(change.after.ref.set(userData, { merge: true }))
  }

  const groupMemberData: any = {}
  groupMemberData[userId] = {
    'last_updated': now,
    'battery': afterUser.battery,
    'location': afterUser.location,
    'name': afterUser.name,
    'image_url': (afterUser.image && ('secure_url' in afterUser.image)) ? afterUser.image.secure_url : null,
    'provider': afterUser.provider,
    'version': afterUser.version
  }

  if (afterUser.connectivity && (afterUser.connectivity.status !== null)) {
    groupMemberData[userId]['connectivity'] = afterUser.connectivity
  }

  try {
    await Promise.all(promises)

    try {
      // Syncs the user groups
      await groupUtils.syncMemberGroups(userId, groupMemberData)

      // Syncs the nearby locations
      // return userUtils.syncNearByLocations(change.after, userData['near_by'], config).then(() => Promise.resolve('ok'))
      return Promise.resolve('ok')
    } catch (error) {
      console.error(error)
      return Promise.resolve('error')
    }
  } catch (error) {
    console.error(error)
    return Promise.resolve('error')
  }
}

function checkPurchase(
  promises: Promise<any>[],
  context: any,
  beforeUser: any,
  afterUser: any
) {
  const userId: any = context.params.userId
  let messages: any[] = []

  // Push a message to the user if they...
  //   * Subscribed to a product
  //   * Updated their subscription
  //   * Unsubscribed from a product
  if (!beforeUser.purchase && afterUser.purchase) {
    messages = subscriptionUtils.buildAccountSubscribeNotification(userId)
  } else if (beforeUser.purchase && afterUser.purchase && (beforeUser.purchase.purchaseTime !== afterUser.purchase.purchaseTime)) {
    messages = subscriptionUtils.buildAccountSubscriptionUpdateNotification(userId)
  } else if (beforeUser.purchase && !afterUser.purchase) {
    messages = subscriptionUtils.buildAccountUnsubscribeNotification(userId)
  }

  if (messages.length) {
    messages.forEach((message) => promises.push(admin.firestore().collection('messages').add(message)))
  }
}
