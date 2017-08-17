//
//  Message.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 13/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit
import Firebase

/// Represents single message in chat
class Message: NSObject, MessageProtocol {
    let body: String
    let id: String
    let sender: String
    let time: Int
    
    /// Get whole message assigned to channel
    ///
    /// - Parameters:
    ///   - channelId: String with channelId from which messages will be taken
    ///   - completionHandler: [Message] array if there is any messages
    class func getAllMessages(for channelId: String, completionHandler: @escaping (Result<[Message]>) -> Void) {
        let ref = Database.database().reference().child("channels").child(channelId).child("messages")
        ref.observeSingleEvent(of: .value, with: { (snap) in
            if snap.exists() {
                if let messagesDict = snap.value as? [String: Any] {
                    let messages = messagesDict.map { dict -> Message in
                        let newMessageDict = dict.value as! [String: Any]
                        return Message(
                        body: newMessageDict["body"] as! String,
                        id: newMessageDict["id"] as! String,
                        sender: newMessageDict["sender"] as! String,
                        time: newMessageDict["time"] as! Int) }
                    completionHandler(Result.success(messages.sorted(by: {$0.0.time < $0.1.time})))
                }
            } else {
                completionHandler(Result.success([]))
            }
        })
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
    class func send(message: String, channelId: String, completionHandler: @escaping (Result<EmptySuccess>) -> Void) {
        Database.database().reference().child("channels").child(channelId).child("messages").observeSingleEvent(of: .value, with: { (snap) in
            let ref = snap.ref.childByAutoId()
            let key = ref.key
            let timestamp = Int(Date().timeIntervalSince1970 * 1000)
            let userUid = ChatUser.currentUser!.uid
            let values: [String: Any] = ["body" : message, "id": key, "sender": userUid, "time": timestamp]
            ref.setValue(values, withCompletionBlock: { (error, _) in
                if let error = error {
                    completionHandler(Result.failure(error))
                } else {
                    completionHandler(Result.success(EmptySuccess()))
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
    required init(body: String, id: String, sender: String, time: Int) {
        self.body = body
        self.id = id
        self.sender = sender
        self.time = time
    }
}
