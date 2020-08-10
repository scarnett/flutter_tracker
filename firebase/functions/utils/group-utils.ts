import * as admin from 'firebase-admin'

export function getGroup(groupId: any): FirebaseFirestore.DocumentReference {
  return admin.firestore()
    .collection('groups')
    .doc(groupId)
}

// Update the group(s) that this user is a member of
export async function syncMemberGroups(userId: any, userData: any): Promise<any> {
  const groupsRef: FirebaseFirestore.Query = admin.firestore()
    .collection('groups')
    .where('member_index', 'array-contains', userId)
    .where('deleted', '==', false)

  try {
    const groupsSnapshot = await groupsRef.get()
    const promises: Array<Promise<any>> = []

    groupsSnapshot.forEach((groupDoc: FirebaseFirestore.QueryDocumentSnapshot) => {
      if (groupDoc.exists) {
        const data: any = {
          'members': userData,
          'last_updated': admin.firestore.FieldValue.serverTimestamp()
        }

        // Update the owner info
        const group: any = groupDoc.data()
        if ((group.owner.uid === userId) && userData[userId] && userData[userId].name) {
          data['owner'] = {
            'name': userData[userId].name
          }
        }

        if (group.members) {
          // Set the initial location sharing status if this is a new member
          if (!group.members[userId]['location_sharing']) {
            data['members'][userId]['location_sharing'] = {
              'status': true
            }
          }

          // Set the initial activity detection status if this is a new member
          if (!group.members[userId]['activity_detection']) {
            data['members'][userId]['activity_detection'] = {
              'status': true
            }
          }
        }

        // Sync the member data to the group doc
        promises.push(groupDoc.ref.set(data, { merge: true }))
      }
    })

    return Promise.all(promises)
  } catch (error) {
    return await Promise.reject(error)
  }
}

// Removes a user from the group(s) that the user is a member of in the event that the user is deleted.
// If the user if the owner of the group then the entire group will be flagged as deleted.
export async function deleteMemberFromGroups(userId: any): Promise<any> {
  const groupsRef: FirebaseFirestore.Query = admin.firestore()
    .collection('groups')
    .where('member_index', 'array-contains', userId)
    .where('deleted', '==', false)

  try {
    const groupsSnapshot = await groupsRef.get()
    const promises: Array<Promise<any>> = []

    groupsSnapshot.forEach((groupDoc: any) => {
      const groupData: any = groupDoc.data()
      const data: any = {}

      // Delete the group if the user is the owner
      if (groupData.owner.uid === userId) {
        data['deleted'] = true
      }

      // Remove from 'members' map
      const updatedMembers: any = groupData.members
      delete updatedMembers[userId]

      // Remove from 'member_index' array
      const updatedMemberIndex: string[] = groupData.member_index
      const index: number = updatedMemberIndex.indexOf(userId, 0)
      if (index > -1) {
        updatedMemberIndex.splice(index, 1)
      }

      data['members'] = updatedMembers
      data['member_index'] = updatedMemberIndex
      data['last_updated'] = admin.firestore.FieldValue.serverTimestamp()

      // Sync the member data to the group doc
      promises.push(groupDoc.ref.set(data, { merge: true }))
    })

    return Promise.all(promises)
  } catch (error) {
    return await Promise.reject(error)
  }
}
