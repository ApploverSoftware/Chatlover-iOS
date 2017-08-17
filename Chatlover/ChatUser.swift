//
//  User.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 13/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit
import Firebase

class APIError: Error {
    var localizedDescription: String
    
    init(localizedDescription: String = "") {
        self.localizedDescription = localizedDescription
    }
}

class ChatUser: NSObject {
    var fcmToken: String
    var uid: String
    var name: String?
    
    static var currentUser: ChatUser?
    
    /// Create ChatUser object in depends of Auth.auth().currentUser.
    /// When you call this function, you have to be sure that you are
    /// logged.
    //
    /// - Parameter completionHandler: ChatUser if success otherwise error
    class func createChatUser(completionHandler: @escaping (Result<ChatUser>) -> Void) {
        if let currentUser = Auth.auth().currentUser {
            if let token = Messaging.messaging().fcmToken {
                let name = currentUser.displayName
                let uid = currentUser.uid
                let fcmToken = token
                let values = ["fcmToken": fcmToken, "name" : name, "uid": uid]
                Database.database().reference().child("chat_users").child(uid).setValue(values, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        completionHandler(Result.failure(error))
                    } else {
                        ref.observeSingleEvent(of: .value, with: { (snapshot) in
                            if let value = snapshot.value as? [String: String] {
                                let chatUser = ChatUser(fcmToken: value["fcmToken"]!, name: value["name"], uid: value["uid"]!)
                                completionHandler(Result.success(chatUser))
                            } else {
                                let error = APIError(localizedDescription: "Can't get value as [String: Any] from snapshot")
                                completionHandler(Result.failure(error))
                            }
                        })
                    }
                })
            }
            let error = APIError(localizedDescription: "Can't get fcmToken")
            completionHandler(Result.failure(error))
        } else {
            let error = APIError(localizedDescription: "You need to be logged before calling this function")
            completionHandler(Result.failure(error))
        }
    }
    
    /// Get object of Chat user
    ///
    /// - Parameters:
    ///   - uid: String with id of user
    ///   - completionHandler: Return ChatUser if success otherwise Error
    class func getChatUser(withId uid: String, completionHandler: @escaping (Result<ChatUser>) -> Void) {
        Database.database().reference().child("chat_users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                if let value = snapshot.value as? [String: String] {
                    let chatUser = ChatUser(fcmToken: value["fcmToken"]!, name: value["name"], uid: value["uid"]!)
                    completionHandler(Result.success(chatUser))
                } else {
                    let error = APIError(localizedDescription: "Can't get value as [String: Any] from snapshot")
                    completionHandler(Result.failure(error))
                }
            } else {
                createChatUser(completionHandler: completionHandler)
            }
        })
    }

    /// Obser registration of users
    ///
    /// - Parameter completionHandler: Return [User] array of registered users if success, otherwise Error
    class func observRegisteredUsers(completionHandler: @escaping (Result<[ChatUser]>) -> Void) {
        Database.database().reference().child("chat_users").observe(.value, with: { (snap) in
            if snap.exists() {
                let values = snap.value as! [String: Any]
                let keys = values.map { $0.key }.filter { $0 != currentUser!.uid }
                let users = keys.map { u -> ChatUser in
                    let userDict = values[u] as! [String: String]
                    let userName = userDict["name"]
                    let fcmToken = userDict["fcmToken"]!
                    let userUid = userDict["uid"]!
                    return ChatUser(fcmToken: fcmToken, name: userName, uid: userUid)
                }
                completionHandler(Result.success(users))
            } else {
                completionHandler(Result.success([]))
            }
        })
    }
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - fcmToken: String with token for cloud messaging
    ///   - name: String with name of user
    ///   - uid: String with uid of user
    init(fcmToken: String, name: String?, uid: String) {
        self.fcmToken = fcmToken
        self.uid = uid
        self.name = name
    }
}
