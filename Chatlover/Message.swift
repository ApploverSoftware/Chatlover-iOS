//
//  Message.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 13/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit
import Firebase

enum Result<T> {
    case success(T)
    case failure(Error)
}

class Message: NSObject {
    // Text message content
    var body: String
    
    // Id of message
    var id: String
    
    // Id of user
    var sender: String
    
    // Timestmp
    var time: Int
    
    // True if message belongs to current logged user
    var receiverMessage: Bool {
        get {
            return User.currentUser!.uid == sender
        }
    }
    
    
    /// Download all message for particular channel
    ///
    /// - Parameters:
    ///   - channelId: String with channel id
    ///   - completionHandler: Result<[Message]> with whole messages
    class func downloadAllMessages(for channelId: String, completionHandler: @escaping (Result<[Message]>) -> Void) {
        Database.database().reference().child("channels").child(channelId).observe(.value, with: { (snapshot) in
            guard snapshot.exists() else {
                return
            }
            
            let data = snapshot.value as! [String: Any]
        })
    }
    
    class func observMessages(for channelId: String, completionHandler: @escaping (Result<Message>) -> Void) -> (handler: UInt, ref: DatabaseReference) {
        let ref = Database.database().reference().child("channels").child(channelId).child("messages")
        let handler = ref.observe(.childAdded, with: { (snap) in
            if snap.exists() {
                if let messageDict = snap.value as? [String : Any] {
                    print(messageDict)
                    let message = Message.from(dictionary: messageDict)
                    completionHandler(Result.success(message))
                }
            }
        })
        return (handler: handler, ref: ref)
    }
    
    
    /// Send message to particular channelId
    ///
    /// - Parameters:
    ///   - message: Message object with content
    ///   - channelId: String with channel id to which message will be send
    ///   - completionHandler: True if success otherwise false
    class func send(message: String, channelId: String, completionHandler: @escaping (Bool) -> Void) {
        Database.database().reference().child("channels").child(channelId).child("messages").observeSingleEvent(of: .value, with: { (snap) in
            let ref = snap.ref.childByAutoId()
            let key = ref.key
            let timestamp = Int(Date().timeIntervalSince1970)
            let userUid = User.currentUser!.uid
            let values: [String: Any] = ["body" : message, "id": key, "sender": userUid, "time": timestamp]
            ref.setValue(values, withCompletionBlock: { (error, _) in
                if error != nil {
                    completionHandler(false)
                } else {
                    completionHandler(true)
                }
            })
        })
        
    }
    
    init(body: String, id: String, sender: String, time: Int) {
        self.body = body
        self.id = id
        self.sender = sender
        self.time = time
    }
    
    static func from(dictionary: [String: Any]) -> Message {
        return Message(body: dictionary["body"] as! String, id: dictionary["id"] as! String, sender: dictionary["sender"] as! String, time: dictionary["time"] as! Int)
    }
}
