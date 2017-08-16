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
class Channel: NSObject {
    let id: String
    let name: String
    let usersIds: [String]
    
    /// Function to download whole channels
    ///
    /// - Parameter completionHandler: [Channel] array of channels otherwise Error
    class func fetchChannels(completionHandler: @escaping (Result<[Channel]>) -> Void) {
        Database.database().reference().child("channels").observeSingleEvent(of: .value, with: { (snap) in
            guard let channelsDict = snap.value as? [String : Any] else {
                completionHandler(Result.success([]))
                return
            }
            let channelsDicts = channelsDict.map { $0.value as! [String : Any] }
            let channels = channelsDicts.map { Channel(dict: $0) }
            completionHandler(Result.success(channels))
        })
    }
    
    /// Function to create channel with given name
    ///
    /// - Parameters:
    ///   - withName: String with name of new channel
    ///   - completionHandler: True if success otherwise Error
    class func createNewChannel(withName: String, completionHandler: @escaping (Result<Bool>) -> Void) {
        let ref = Database.database().reference().child("channels").childByAutoId()
        let key = ref.key
        let values = ["id": key, "name" : withName]
        ref.setValue(values) { (error, _) in
            if let error = error {
                completionHandler(Result.failure(error))
            } else {
                completionHandler(Result.success(true))
            }
        }
    }
    
    /// Function for join to particular channel by current logged user
    ///
    /// - Parameters:
    ///   - channelId: String with channel id to which current user will join
    ///   - completionHandler: True if successful
    class func joinToChannel(withId channelId: String, completionHandler: @escaping (Result<Bool>) -> Void) {
        Database.database().reference().child("channels").child(channelId).child("users").observeSingleEvent(of: .value, with: { (snap) in
            if snap.exists() {
                let dictOfUsers = snap.value as! [String : Any]
                let userUid = User.currentUser!.uid
                if dictOfUsers[userUid] == nil {
                    let ref = snap.ref.child(userUid)
                    let values = ["uid" : userUid]
                    ref.setValue(values)
                    completionHandler(Result.success(true))
                } else {
                    completionHandler(Result.success(true))
                }
            } else {
                let userUid = User.currentUser!.uid
                let ref = Database.database().reference().child("channels").child(channelId).child("users").child(userUid)
                let values = ["uid" : userUid]
                ref.setValue(values)
                completionHandler(Result.success(true))
            }
        })
    }
    
    /// Function for join to particular channel by group of users
    ///
    /// - Parameters:
    ///   - channelId: String with channel id to which users will be added
    ///   - usersId: [String] with users uid
    ///   - completionHandler: True uf successful
    class func joinToChannel(withId channelId: String, usersId: [String], completionHandler: @escaping (Result<Bool>) -> Void) {
        Database.database().reference().child("channels").child(channelId).child("users").observeSingleEvent(of: .value, with: { (snap) in
            if snap.exists() {
                let dictOfUsers = snap.value as! [String : Any]
                usersId.forEach { userId in
                    if dictOfUsers[userId] == nil {
                        let ref = snap.ref.child(userId)
                        let values = ["uid" : userId]
                        ref.setValue(values)
                    }
                }
                completionHandler(Result.success(true))
            } else {
                let ref = Database.database().reference().child("channels").child(channelId).child("users")
                var usersDict: [String : Any] = [:]
                usersId.forEach { (id) in usersDict[id] = ["uid" : usersId] }
                let values = ["users" : usersDict]
                ref.setValue(values)
                completionHandler(Result.success(true))
            }
        })
    }
    
    /// Intializer
    ///
    /// - Parameters:
    ///   - dict: Dictionary with Channel data
    init(dict: [String: Any]) {
        self.id = dict["id"] as! String
        self.name = dict["name"] as! String
        if let userDicts = dict["users"] as? [String: Any] {
            let ids = userDicts.map { $0.key }
            self.usersIds = ids
        } else {
            self.usersIds = []
        }
    }
}
