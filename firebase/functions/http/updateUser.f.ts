import * as httpUtils from '../utils/http-utils'
import * as userUtils from '../utils/user-utils'
import * as admin from 'firebase-admin'

/**
 * This endpoint is used to handle updates coming from the user devices
 */
exports.update_user = httpUtils.appEndpoints.post('/update', (req: any, res: any): any => {
  return userUtils.getUserByAuthToken(req)
    .then((userSnap: any) => {
      const params: any = req.query
      const types: string[] = getTypes(params.types)
      const promises: Array<Promise<any>> = []

      if (types.length) {
        userSnap.forEach((userDoc: any) => {
          let hasData: boolean = false
          const userData: any = {
            'last_updated': admin.firestore.FieldValue.serverTimestamp()
          }

          types.forEach(type => {
            switch (type) {
              case 'battery':
              case 'connectivity':
              case 'location':
              case 'provider':
                hasData = true
                userData[type] = req.body[type]

              default:
                // console.log(type, req.body[type])
                break
            }
          })

          if (hasData) {
            // If we get a list of data then just grab the last one
            if (userData['location'] instanceof Array) {
              const locations: any[] = userData['location']
              if (locations.length) {
                const location: any = locations[locations.length - 1]
                userData['location'] = location
              }
            }

            const userLocation: any = userData['location']
            if (userLocation && userData && ('battery' in userLocation) && !('battery' in userData)) {
              const userBattery: any = userLocation['battery']
              userData['battery'] = {
                'charging': userBattery['is_charging'],
                'level': (userBattery['level'] * 100)
              }
            }

            // Updates the user doc
            promises.push(userDoc.ref.set(userData, { merge: true }))
          }
        })

        if (promises.length) {
          return Promise.all(promises)
            .then(() => res.status(200).send('ok'))
            .catch((error: any) => {
              console.error(error)
              return res.status(401).send('error')
            })
        }
      }

      return res.status(200).send('ok')
    })
    .catch((error: any) => {
      console.error(error)
      return res.status(401).send('error')
    })
})

// Allows us to update multiple types at once
function getTypes(type: string): string[] {
  if (type === null) {
    return []
  }

  const types: string[] = type.split(',')
  return types
}
