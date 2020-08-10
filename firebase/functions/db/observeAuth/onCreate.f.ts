import * as admin from 'firebase-admin'
import * as functions from 'firebase-functions'

/**
 * This observes the auth users being created in the system.
 */
exports = module.exports = functions.auth.user().onCreate(async (user) => {
  const now: admin.firestore.FieldValue = admin.firestore.FieldValue.serverTimestamp()
  const promises: Array<Promise<any>> = []

  const userName: string | undefined = user.displayName || user.email
  const authToken = admin.auth().createCustomToken(user.uid)

  const groupData: any = {
    'admins': [user.uid],
    'member_index': [user.uid],
    'owner': {
      'uid': user.uid
    },
    'members': {},
    'name': 'Family', // TODO
    'created': now,
    'last_updated': now,
    'deleted': false
  }

  groupData['members'][user.uid] = {
    'name': userName,
    'location': {},
    'location_sharing': {
      'status': true
    },
    'activity_detection': {
      'status': true
    }
  }

  // Create the initial group doc
  promises.push(admin.firestore().collection('groups').add(groupData)
    .then(groupRef => {
      const plist: Array<Promise<any>> = []

      // Create the user doc
      plist.push(admin.firestore().doc(`users/${user.uid}`).set({
        'auth': {
          'token': authToken
        },
        'name': userName,
        'last_updated': now,
        'primary_group': groupRef.id,
        'active_group': groupRef.id,
        'battery': {},
        'connectivity': {},
        'location': {},
        'image': {},
        'events': {}
      }))

      // Update the owners name
      plist.push(groupRef.update({
        'owner': {
          'uid': user.uid,
          'name': userName
        }
      }))

      return Promise.all(plist)
    })
    .catch((error: any) => {
      console.error(error)
      return Promise.resolve('error')
    })
  )

  // TODO: Send welcome email

  try {
    await Promise.all(promises)
    return await Promise.resolve('ok')
  } catch (error) {
    console.error(error)
    return Promise.resolve('error')
  }
})
