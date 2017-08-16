//
//  Channel.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 13/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit
import Firebase

class Channel: NSObject {
    var id: String = ""
    var name: String = ""
    
    class func observChannels(completionHandler: @escaping (Result<[Channel]>) -> Void) {
        Database.database().reference().child("channels").observeSingleEvent(of: .value, with: { (snap) in
            guard let channelsDict = snap.value as? [String : Any] else {
                completionHandler(Result.success([]))
                return
            }
            let channelsDicts = channelsDict.map { $0.value as! [String : Any] }
            let channels = channelsDicts.map { Channel.from(dictionary: $0) }
            completionHandler(Result.success(channels))
        })
    }
    
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
    
    class func joinToChannel(withId: String, completionHandler: @escaping (Result<Bool>) -> Void) {
        Database.database().reference().child("channels").child(withId).child("users").observeSingleEvent(of: .value, with: { (snap) in
            if snap.exists() {
                let dictOfUsers = snap.value as! [String : Any]
                let userUid = User.currentUser!.uid
                if dictOfUsers[userUid] == nil {
                    let ref = snap.ref.child(userUid)
                    let values = ["uid" : userUid]
                    ref.setValue(values, withCompletionBlock: { (error, _) in
                        if let error = error {
                            completionHandler(Result.failure(error))
                        } else {
                            completionHandler(Result.success(true))
                        }
                    })
                } else {
                    completionHandler(Result.success(true))
                }
            } else {
                let userUid = User.currentUser!.uid
                let ref = Database.database().reference().child("channels").child(withId).child("users").child(userUid)
                let values = ["uid" : userUid]
                ref.setValue(values, withCompletionBlock: { (error, _) in
                    if let error = error {
                        completionHandler(Result.failure(error))
                    } else {
                        completionHandler(Result.success(true))
                    }
                })
            }
        })
    }
    
    static func from(dictionary: [String : Any]) -> Channel {
        let channel = Channel()
        channel.id = dictionary["id"] as! String
        channel.name = dictionary["name"] as! String
        return channel
    }
}
