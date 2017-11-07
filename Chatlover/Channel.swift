//
//  Channel.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 13/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit
import Firebase


/// Represents single channel
class Channel: NSObject, ChatObjectProtocol {
    var id: String
    var name: String
    var users: [ChatUser] = []
    var messages: [Message] = []
    var picture: String?
    
    /// Function to download whole channels from database
    ///
    /// - Parameter completionHandler: [Channel] array of channels otherwise Error
    class func fetchAll(completionHandler: @escaping (Result<[Channel]>) -> Void) {
        Database.database().reference().child("channels").observeSingleEvent(of: .value, with: { (snap) in
            guard let channelsDict = snap.value as? [String : Any] else {
                completionHandler(Result.success([]))
                return
            }
            let channels = channelsDict.flatMap { Channel(dictionary: $0.value as! [String : Any]) }
            completionHandler(Result.success(channels))
        })
    }
    
    /// Function return channel from given id
    ///
    /// - Parameters:
    ///   - id: String with channel id
    ///   - completionHandler: Return Channel if success otherwise
    class func fetch(channelId: String, completionHandler: @escaping (Result<Channel>) -> Void) {
        Database.database().reference().child("channels").child(channelId).observeSingleEvent(of: .value, with: { (snap) in
            guard let channelDict = snap.value as? [String : Any], let channel = Channel(dictionary: channelDict) else {
                let apiError = APIError(localizedDescription: "Channel with id \(channelId) does not exists or can't create instance")
                completionHandler(Result.failure(apiError))
                return
            }
            completionHandler(Result.success(channel))
        })
    }
    
    /// Function to create channel with given name
    ///
    /// - Parameters:
    ///   - withName: String with name of new channel
    ///   - completionHandler: True if success otherwise Error
    class func create(withName: String, users: [ChatUser] = [], completionHandler: @escaping (Result<Channel>) -> Void) {
        let ref = Database.database().reference().child("channels").childByAutoId()
        let key = ref.key
        var values: [String : Any] = ["id": key, "name" : withName]
        
        if users.count > 0 {
            var userDict: [String : Any] = [:]
            users.forEach({ (cUser) in
                userDict[cUser.uid] = cUser.toDictionary()
            })
            values["users"] = userDict
        }
        
        ref.setValue(values) { (error, _) in
            if let error = error {
                completionHandler(Result.failure(error))
            } else {
                let channel = Channel(dictionary: values)!
                completionHandler(Result.success(channel))
            }
        }
    }
    
    /// Function to leave from channel
    ///
    /// - Parameters:
    ///   - channelId: String with channel id
    ///   - completionHandler: EmptySuccess if success otherwise Error
    class func leave(fromChannel channelId: String, completionHandler: @escaping (Result<EmptySuccess>) -> Void) {
        if let userUid = ChatUser.currentUser?.uid {
            Database.database().reference().child("channels").child(channelId).child("users").child(userUid).removeValue(completionBlock: { (error, _) in
                if let error = error {
                    completionHandler(Result.failure(error))
                } else {
                    completionHandler(Result.success(EmptySuccess()))
                }
            })
        }
    }
    
    /// Function for join to particular channel by current logged user
    ///
    /// - Parameters:
    ///   - channelId: String with channel id to which current user will join
    ///   - completionHandler: True if successful
    class func join(toChannel channelId: String, completionHandler: @escaping (Result<EmptySuccess>) -> Void) {
        if let currentChatUser = ChatUser.currentUser {
            Database.database().reference().child("channels").child(channelId).child("users").observeSingleEvent(of: .value, with: { (snap) in
                if snap.exists() {
                    let dictOfUsers = snap.value as! [String : Any]
                    let uid = currentChatUser.uid
                    if dictOfUsers[uid] == nil {
                        let ref = snap.ref
                        let values = [uid: currentChatUser.toDictionary()]
                        ref.setValue(values)
                        completionHandler(Result.success(EmptySuccess()))
                    } else {
                        completionHandler(Result.success(EmptySuccess()))
                    }
                } else {
                    let ref = Database.database().reference().child("channels").child(channelId).child("users")
                    let uid = currentChatUser.uid
                    let values = [uid : currentChatUser.toDictionary()]
                    ref.setValue(values)
                    completionHandler(Result.success(EmptySuccess()))
                }
            })
        }
    }
    
    /// Function for join to particular channel by group of users
    ///
    /// - Parameters:
    ///   - channelId: String with channel id to which users will be added
    ///   - usersId: [String] with users uid
    ///   - completionHandler: True uf successful
    class func join(toChannel channelId: String, usersId: [String], completionHandler: @escaping (Result<EmptySuccess>) -> Void) {
        Database.database().reference().child("channels").child(channelId).child("users").observeSingleEvent(of: .value, with: { (snap) in
            if snap.exists() {
                let dictOfUsers = snap.value as! [String : Any]
                usersId.forEach { userId in
                    if dictOfUsers[userId] == nil {
                        let ref = snap.ref
                        let values = [userId : userId]
                        ref.setValue(values)
                    }
                }
                completionHandler(Result.success(EmptySuccess()))
            } else {
                let ref = Database.database().reference().child("channels").child(channelId).child("users")
                var usersDict: [String : Any] = [:]
                usersId.forEach { (id) in usersDict[id] = id }
                let values = usersDict
                ref.setValue(values)
                completionHandler(Result.success(EmptySuccess()))
            }
        })
    }
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - id: Id of channel
    ///   - name: Name of channel
    ///   - users: Array of users is
    ///   - messages: Array of messages
    ///   - picture: URL to channel picture
    init(id: String, name: String, users: [ChatUser], messages: [Message], picture: String?) {
        self.id = id
        self.name = name
        self.users = users
        self.messages = messages
        self.picture = picture
    }
}

