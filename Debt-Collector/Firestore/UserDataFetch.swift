//
//  UserDataFetch.swift
//  Debt-Collector
//
//  Created by user248613 on 11/29/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
let userFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("userFile.json")
let groupFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("groupFile.json")
let friendsFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("friendsFile.json")
private let userCollection: CollectionReference = Firestore.firestore().collection("users")
private func userDocument(userId: String) -> DocumentReference {
    userCollection.document(userId)
}
private func groupUserCollection(userId: String) -> CollectionReference {
    userDocument(userId: userId).collection("groups")
}
private func friendCollection(userId: String) -> CollectionReference{
    userDocument(userId: userId).collection("friends")
}
let currentUser = Auth.auth().currentUser
func getAllUserDataForCurrentUser() async throws -> (User, [GroupModel],[FriendshipModel]) {
        var uidRaw = Auth.auth().currentUser?.uid
        let uid = uidRaw!

        // Fetch the user data
        let userSnapshotRaw = try? await Firestore.firestore().collection("users").document(uid).getDocument()
        let userSnapshot = userSnapshotRaw!
        let userDataRaw = try? userSnapshot.data(as: User.self)
        let userData = userDataRaw!
        // Fetch the groups associated with the user
        let groupUserSnapshots = try await groupUserCollection(userId: uid).getDocuments(as: GroupUser.self)
        var groupModels: [GroupModel] = []
        let friendshipSnapshots = try await friendCollection(userId: uid).getDocuments(as: FriendshipModel.self)
        var friendshipModels: [FriendshipModel] = []
        for friendshipSnapshot in friendshipSnapshots {
            friendshipModels.append(friendshipSnapshot)
        }
        for groupUser in groupUserSnapshots {
            let groupId = groupUser.groupId

            // Fetch each group's data
            do {
                let groupModel = try await GroupManager.shared.getGroup(groupId: groupId)
                groupModels.append(groupModel)
            } catch {
                // Handle errors when fetching group data
                print("Failed to fetch group data for group ID \(groupId): \(error)")
            }
        }

        return (userData, groupModels, friendshipModels)
    }
func fetchDataAndWriteToFile() async {

    do {
        let (userData, groupModels, friendshipModels) = try await getAllUserDataForCurrentUser()

        // Convert data to JSON format
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted

        let userDataJSON = try jsonEncoder.encode(userData)
        let groupModelsJSON = try jsonEncoder.encode(groupModels)
        let friendModelJSON = try jsonEncoder.encode(friendshipModels)
        // Write data to the existing JSON files
        try userDataJSON.write(to: userFileURL, options: .atomic)
        try groupModelsJSON.write(to: groupFileURL, options: .atomic)
        try friendModelJSON.write(to: friendsFileURL, options: .atomic)
        print("Data written to \(userFileURL.path) and \(groupFileURL.path) and \(friendsFileURL.path)")
    } catch {
        print("Error fetching or writing data: \(error)")
    }
}
