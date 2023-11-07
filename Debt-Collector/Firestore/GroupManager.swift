//
//  GroupManager.swift
//  Debt-Collector
//
//  Created by Martin Sir on 04.11.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

final class GroupManager {
    
    static let shared = GroupManager()
    private init () {}
        
    private let groupCollection = Firestore.firestore().collection("groups")
    
    private func groupDocument(groupId: String) -> DocumentReference {
        groupCollection.document(groupId)
    }
    
    func uploadGroup(name: String, currency: String, image: Data) async throws {
        let groupRef = groupCollection.document()
        let group = GroupModel(id: groupRef.documentID, name: name, currency: currency, image: image)
        try groupRef.setData(from: group, merge: false)
        let userId = Auth.auth().currentUser?.uid ?? ""
        try await UserManager.shared.addGroupUser(userId: userId, groupId: groupRef.documentID)
    }
    
    func getGroup(groupId: String) async throws -> GroupModel {
        try await groupDocument(groupId: groupId).getDocument(as: GroupModel.self)
    }
    
    func getAllUserGroups(userId: String) {
        // TODO:
    }
}

extension Query {
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        let snapshot = try await self.getDocuments()
        return try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
    }
}
