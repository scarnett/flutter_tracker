import * as admin from 'firebase-admin'
import * as functions from 'firebase-functions'

/**
 * This observes a group being created in the system.
 */
exports = module.exports = functions.firestore
  .document('groups/{groupId}').onCreate(async (group: any) => {
    const promises: Array<Promise<any>> = []
    const data: any = group.data()
    if (data && !data.members) {
      const initialMemberUid: any = data['member_index'][0]
      const initialMemberData: any = {}
      initialMemberData[initialMemberUid] = {}

      // Add the initial member
      promises.push(group.ref.update({
        'members': initialMemberData
      }))

      // Sync the initial group member data
      try {
        await Promise.all(promises)

        try {
          await admin.firestore().doc(`users/${initialMemberUid}`).update({
            'last_updated': admin.firestore.FieldValue.serverTimestamp()
          })

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

    try {
      await Promise.all(promises)
      return await Promise.resolve('ok')
    } catch (error) {
      console.error(error)
      return Promise.resolve('error')
    }
  })
