import * as admin from 'firebase-admin'
import * as functions from 'firebase-functions'

/**
 * This observes the groups being updated in the system.
 */
exports = module.exports = functions.firestore
  .document('groups/{groupId}').onUpdate((change: any, context: any) => {
    const beforeGroup: any = change.before.data()
    const afterGroup: any = change.after.data()
    if ((beforeGroup && afterGroup) &&
      (beforeGroup.last_updated && afterGroup.last_updated) &&
      (!beforeGroup.last_updated.isEqual(afterGroup.last_updated))) {
      const promises: Array<Promise<any>> = []

      // Delete the group document if the 'member_index' is null or empty
      const memberIndex: any = afterGroup.member_index
      if ((memberIndex === null) || (memberIndex.length === 0)) {
        promises.push(change.after.ref.set({
          'deleted': true
        }, { merge: true }))
      } else {
        const members: any = {}

        for (const member in afterGroup.members) {
          if (afterGroup.member_index.includes(member)) {
            // members[member] = afterGroup.members[member]
          } else if (afterGroup.admins.includes(member)) {
            // If we land in here then the user is not in the member_index so we should also delete the
            // user from the admins array if it exists there.
            promises.push(change.after.ref.update({
              'admins': admin.firestore.FieldValue.arrayRemove(member)
            }))
          }
        }

        if (Object.keys(members).length > 0) {
          // Sync the group members
          promises.push(change.after.ref.set({
            'members': members
          }, { merge: true }))
        }
      }

      return Promise.all(promises)
        .then(() => Promise.resolve('ok'))
        .catch((error: any) => {
          console.error(error)
          return Promise.resolve('error')
        })
    }

    return Promise.resolve(null)
  })
