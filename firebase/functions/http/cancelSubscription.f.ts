import * as httpUtils from '../utils/http-utils'
import * as playUtils from '../utils/play-utils'
import * as userUtils from '../utils/user-utils'
import * as admin from 'firebase-admin'

/**
 * This endpoint is used to handle subscription cancellations
 */
exports.cancel_subscription = httpUtils.appEndpoints.post('/cancel-subscription', (req: any, res: any): any => {
  return userUtils.getUserByAuthToken(req)
    .then((userSnap: any) => {
      const params: any = req.query
      const promises: Array<Promise<any>> = []
      promises.push(playUtils.unsubscribe(params.subscriptionId, params.purchaseToken))

      // Clears the purchase data
      userSnap.forEach((userDoc: any) => {
        const userData: any = {
          'purchase': null,
          'last_updated': admin.firestore.FieldValue.serverTimestamp()
        }

        // Updates the user doc
        promises.push(userDoc.ref.set(userData, { merge: true }))
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
    .catch((error: any) => {
      console.error(error)
      return res.status(401).send('error')
    })
})
