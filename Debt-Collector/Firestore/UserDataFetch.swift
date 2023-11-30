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
private let userCollection: CollectionReference = Firestore.firestore().collection("users")
private func userDocument(userId: String) -> DocumentReference {
    userCollection.document(userId)
}
private func groupUserCollection(userId: String) -> CollectionReference {
    userDocument(userId: userId).collection("groups")
}
let currentUser = Auth.auth().currentUser
func getAllUserDataForCurrentUser() async throws -> (User, [GroupModel]) {
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

        return (userData, groupModels)
    }
func fetchDataAndWriteToFile() async {
    do {
        let (userData, groupModels) = try await getAllUserDataForCurrentUser()

        // Convert data to JSON format
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted

        let userDataJSON = try jsonEncoder.encode(userData)
        let groupModelsJSON = try jsonEncoder.encode(groupModels)

        // Get the document directory
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Create a URL for your JSON file
            let userDataURL = documentDirectory.appendingPathComponent("userData.json")
            let groupModelsURL = documentDirectory.appendingPathComponent("groupModels.json")

            // Write data to the JSON files
            try userDataJSON.write(to: userDataURL, options: .atomic)
            try groupModelsJSON.write(to: groupModelsURL, options: .atomic)

            print("Data written to \(userDataURL.path) and \(groupModelsURL.path)")
        }
    } catch {
        print("Error fetching or writing data: \(error)")
    }
}
