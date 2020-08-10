import * as functions from 'firebase-functions'
import * as utils from '../../utils/utils'
import * as userUtils from '../../utils/user-utils'
import * as messageUtils from '../../utils/message-utils'
import * as messageModel from '../../models/message'

/**
 * This observes the messages being created in the system.
 */
exports = module.exports = functions.firestore
  .document('messages/{messageId}').onCreate((message: any) => {
    const promises: Array<Promise<any>> = []
    const data: any = message.data()
    if (data) {
      const extraData: any = data.meta ? data.meta.extraData : null || null

      if ((data.fromUid === undefined) && (data.toUid !== undefined)) {
        promises.push(
          userUtils.getUser(data.toUid)
            .then((toUserDoc: any) => {
              const toUser: any = (toUserDoc === null) ? null : toUserDoc.data()
              if (toUser && message) {
                const messageData: messageModel.Message | null = utils.parseData(data, null, toUser, extraData)

                // TODO: Check to see if the push message recipient is a member of same group as the sender

                // Send the message
                return utils.pushMessage(message, toUser, messageData)
                  .then((res: any) => Promise.resolve('ok'))
                  .catch((error: any) => {
                    console.error(error)
                    return Promise.resolve(null)
                  })
              }

              return Promise.reject(`toUser is null: ${data.toUid}`)
            })
            .catch((error: any) => {
              console.error(error)
              return Promise.resolve(null)
            })
        )
      } else if ((data.fromUid !== undefined) && (data.toUid !== undefined)) {
        promises.push(
          // Get 'from' user
          userUtils.getUser(data.fromUid)
            .then(async (fromUserDoc: FirebaseFirestore.DocumentSnapshot | null) => {
              if (fromUserDoc) {
                const fromUser: any = fromUserDoc.data()
                if (fromUser) {
                  try {
                    // Get 'to' user
                    const toUserDoc = await userUtils.getUser(data.toUid)
                    const toUser: any = (toUserDoc === null) ? null : toUserDoc.data()
                    if (toUser && message) {
                      let messagePromises: Array<Promise<any>> = []
                      const messageData: messageModel.Message | null = utils.parseData(message.data(), fromUser, toUser, extraData)

                      // Add some activity documents to the users if this is a check-in message
                      if (messageData && messageUtils.isType(messageData['data'], messageUtils.MessageType.CHECKIN)) {
                        messagePromises = messagePromises.concat(messageUtils.addCheckinActivities(fromUserDoc, toUserDoc))
                      }

                      // Push the message
                      messagePromises.push(utils.pushMessage(message, toUser, messageData))
                      return Promise.all(messagePromises)
                        .then((res: any) => Promise.resolve('ok'))
                        .catch((error: any) => {
                          console.error(error)
                          return Promise.resolve(null)
                        })
                    }

                    return Promise.reject(`toUser is null: ${data.toUid}`)
                  } catch (error) {
                    console.error(error)
                    return Promise.resolve(null)
                  }
                }

                return Promise.reject(`fromUser is null: ${data.fromUid}`)
              }

              return Promise.reject(`fromUserDoc is null: ${data.fromUid}`)
            })
            .catch((error: any) => {
              console.error(error)
              return Promise.resolve(null)
            })
        )
      }

      return Promise.resolve(null)
    }

    return Promise.all(promises)
      .then(() => Promise.resolve('ok'))
      .catch((error: any) => {
        console.error(error)
        return Promise.resolve('error')
      })
  })
