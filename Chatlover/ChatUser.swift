//
//  User.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 13/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit
import Firebase

let defaultMaleImage = "profileMan"
let defaultFemaleImage = "profileWoman"

class ChatUser: NSObject, ChatObjectProtocol {
    var uid: String
    var name: String
    var fcmToken: String?
    var avatar: String?
    
    static var currentUser: ChatUser?
    
    /// Function that Create chat user
    ///
    /// - Parameters:
    ///   - uid: UNIQUE id for chat user object (prefered id of Your user/primary model)
    ///   - name: Name of chat user
    ///   - fcmToken: Optional Firebase cloud message token, required when push notifications are on
    ///   - avatar: Optional UIImage with avatar of chat user
    ///   - completionHandler: Return ChatUser if success, otherwise Error
    class func create(uid: String, name: String, fcmToken: String?, avatar: UIImage?, completionHandler: @escaping (Result<ChatUser>) -> Void) {
        if let avatar = avatar, let data = UIImageJPEGRepresentation(avatar, 0.5) {
            let fileName = "\(Date().timeIntervalSince1970 * 1000).jpg"
            let path = uid + "/" + fileName
            Storage.storage().reference().child("chatlover").child("chat_user").child(path).putData(data, metadata: nil, completion: { (metadata, error) in
                guard let metadata = metadata else {
                    let apiError = APIError(localizedDescription: "Can't save image in path: \(path)")
                    completionHandler(Result.failure(apiError))
                    return
                }
                let downloadURL = metadata.downloadURL()
                let chatUser = ChatUser(uid: uid, name: name, fcmToken: fcmToken, avatar: downloadURL?.absoluteString)
                save(model: chatUser, completionHandler: completionHandler)
            })
        } else {
            let chatUser = ChatUser(uid: uid, name: name, fcmToken: fcmToken, avatar: nil)
            save(model: chatUser, completionHandler: completionHandler)
        }
    }
    
    /// Save created ChatUser model into firebase
    ///
    /// - Parameters:
    ///   - model: ChatUser model which you want to save
    ///   - completionHandler: Return given `model` if success otherwsie Error
    private class func save(model: ChatUser, completionHandler: @escaping (Result<ChatUser>) -> Void) {
        Database.database().reference().child("chat_users").child(model.uid).setValue(model.toDictionary(), withCompletionBlock: { (error, ref) in
            if let error = error {
                completionHandler(Result.failure(error))
            } else {
                completionHandler(Result.success(model))
            }
        })
    }
    
    /// Get chat user object
    ///
    /// - Parameters:
    ///   - uid: If of chat user which you want to fetch
    ///   - completionHandler: Return ChatUser if success otherwise Error
    class func fetch(withId uid: String, completionHandler: @escaping (Result<ChatUser>) -> Void) {
        Database.database().reference().child("chat_users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                if let value = snapshot.value as? [String: String], let chatUser = ChatUser(dictionary: value) {
                    completionHandler(Result.success(chatUser))
                } else {
                    let error = APIError(localizedDescription: "Can't get value from snap or create model from value")
                    completionHandler(Result.failure(error))
                }
            } else {
                let apiError = APIError(localizedDescription: "Chat user with uid: \(uid) does not exists in chat_users child")
                completionHandler(Result.failure(apiError))
            }
        })
    }
    
    /// Obser registerd chat users
    ///
    /// - Parameter completionHandler: Return [User] array of registered users if success, otherwise Error
    class func observRegistered(completionHandler: @escaping (Result<[ChatUser]>) -> Void) {
        Database.database().reference().child("chat_users").observe(.value, with: { (snap) in
            if snap.exists() {
                let values = snap.value as! [String : Any]
                var keys = values.map { $0.key }
                if let currentChatUserUid = currentUser?.uid {
                    keys = keys.filter { $0 != currentChatUserUid }
                }
                let users = keys.flatMap { ChatUser(dictionary: values[$0] as! [String : String]) }
                completionHandler(Result.success(users))
            } else {
                completionHandler(Result.success([]))
            }
        })
    }
    
    /// Fetch channel to which chat user is assigned
    ///
    /// - Parameter completionHandler: Return array of Channel otherwise Error
    func fetchChannels(completionHandler: @escaping (Result<[Channel]>) -> Void) {
        Database.database().reference().child("channel_by_user").child(uid).observe(.value, with: { (snap) in
            if snap.exists() {
                guard let value = snap.value as? [String : Any] else {
                    let apiError = APIError(localizedDescription: "Can't get value from snap")
                    completionHandler(Result.failure(apiError))
                    return
                }
                
                let channels = value.flatMap { Channel(dictionary: $0.value as! [String : Any]) }
                
                completionHandler(Result.success(channels))
            } else {
                completionHandler(Result.success([]))
            }
        })
    }
    
    /// Get image for current user
    ///
    /// - Parameter completionHandler: UIImage if success otherwise error
    func getProfilePic(completionHandler: @escaping (UIImage) -> Void) {
        if let profilePic = avatar {
            Storage.storage().reference().child(uid).child("photo/\(profilePic).jpg").getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if let _ = error {
                    let defaultImage = UIImage(named: defaultMaleImage)!
                    DispatchQueue.main.async {
                        completionHandler(defaultImage)
                    }
                    
                } else {
                    let image = UIImage(data: data!)!
                    DispatchQueue.main.async {
                        completionHandler(image)
                    }
                }
            })
        } else {
            let defaultImage = UIImage(named: defaultMaleImage)!
            completionHandler(defaultImage)
        }
    }
    
    /// Default intializer
    ///
    /// - Parameters:
    ///   - uid: UNIQUE id of chat user (prefered to be same as Your base model like user model
    ///   - name: Name of chat user
    ///   - fcmToken: Firebase cloud message token, required when push notifications are on
    ///   - avatar: URL to avatar
    init(uid: String, name: String, fcmToken: String?, avatar: String?) {
        self.uid = uid
        self.name = name
        self.fcmToken = fcmToken
        self.avatar = avatar
    }
}

