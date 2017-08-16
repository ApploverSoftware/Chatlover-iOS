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

/// Represents single message in chat
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
    
    var timeText: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE HH:mm"
            let date = Date(timeIntervalSince1970: Double(time / 1000))
            return formatter.string(from: date)
        }
    }
    
    /// Observing messages for given channel
    ///
    /// - Parameters:
    ///   - channelId: String with channelId which will be observing
    ///   - completionHandler: Message object for every single update
    /// - Returns: Ref and handler of observer. Need for remove when controller disappear
    class func observMessages(for channelId: String, completionHandler: @escaping (Result<Message>) -> Void) -> (handler: UInt, ref: DatabaseReference) {
        let ref = Database.database().reference().child("channels").child(channelId).child("messages")
        let handler = ref.observe(.childAdded, with: { (snap) in
            if snap.exists() {
                if let messageDict = snap.value as? [String : Any] {
                    let message = Message(
                        body: messageDict["body"] as! String,
                        id: messageDict["id"] as! String,
                        sender: messageDict["sender"] as! String,
                        time: messageDict["time"] as! Int)
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
            let timestamp = Int(Date().timeIntervalSince1970 * 1000)
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
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - body: String with text of message
    ///   - id: Strign with id of message
    ///   - sender: String with id of user which send this message
    ///   - time: Int with timestamp
    init(body: String, id: String, sender: String, time: Int) {
        self.body = body
        self.id = id
        self.sender = sender
        self.time = time
    }
}
