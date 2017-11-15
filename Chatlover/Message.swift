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
class Message: NSObject, MessageProtocol, ChatObjectProtocol {
    var type: MessageType
    var body: String
    var id: String
    var sender: String
    var time: Double
    
    enum MessageType: String {
        case txt
        case img
        case vid
        case mic
        case loc
    }
    
    /// Get whole message assigned to channel
    ///
    /// - Parameters:
    ///   - channelId: String with channelId from which messages will be taken
    ///   - completionHandler: [Message] array if there is any messages
    class func getAllMessages(for channelId: String, completionHandler: @escaping (Result<[Message]>) -> Void) {
        let ref = Database.database().reference().child("channels").child(channelId).child("messages")
        ref.observeSingleEvent(of: .value, with: { (snap) in
            if snap.exists() {
                if let messagesDict = snap.value as? [String : Any] {
                    debugPrint(messagesDict)
                    let messages = messagesDict.flatMap { Message(dictionary: $0.value as! [String : Any]) }
                    completionHandler(Result.success(messages.sorted(by: {$0.0.time < $0.1.time})))
                } else {
                    completionHandler(Result.success([]))
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
                if let messageDict = snap.value as? [String : Any], let message = Message(dictionary: messageDict) {
                    completionHandler(Result.success(message))
                } else {
                    let apiError = APIError(localizedDescription: "Can't parse Message object")
                    completionHandler(Result.failure(apiError))
                }
            }
        })
        return (handler: handler, ref: ref)
    }
    
    /// Send text message
    ///
    /// - Parameters:
    ///   - message: Content of body
    ///   - channelId: Channel to which message will be saved
    ///   - completionHandler: If saved successfuly then EmptySuccess
    class func sendTextMessage(message: String, channelId: String, completionHandler: @escaping (Result<EmptySuccess>) -> Void) {
        uploadMessage(body: message, type: .txt, channelId: channelId, completionHandler: completionHandler)
    }
    
    /// Send location message
    ///
    /// - Parameters:
    ///   - location: Location in format lat/lng
    ///   - channelId: Channel to which message will be saved
    ///   - completionHandler: If saved successfuly then EmptySuccess
    class func sendLocationMessage(location: String, channelId: String, completionHandler: @escaping (Result<EmptySuccess>) -> Void) {
        uploadMessage(body: location, type: .loc, channelId: channelId, completionHandler: completionHandler)
    }
    
    /// Upload message to firebase
    ///
    /// - Parameters:
    ///   - values: Dictionary which will be uploaded
    ///   - channelId: Channel id to which message will be saved
    ///   - completionHandler: EmptySuccess will be returned when upload succeeded otherwise Error
    private class func uploadMessage(body: String, type: MessageType, channelId: String, completionHandler: @escaping (Result<EmptySuccess>) -> Void) {
        if let chatUserId = ChatUser.currentUser?.uid {
            let timestamp = Double((Date().timeIntervalSince1970 * 1000))
            let ref = Database.database().reference().child("channels").child(channelId).child("messages").childByAutoId()
            let key = ref.key
            let values: [String : Any] = ["id" : key, "body" : body, "type" : type.rawValue, "sender" : chatUserId, "time" : timestamp]
            ref.setValue(values) { (error, _) in
                if let error = error {
                    completionHandler(Result.failure(error))
                } else {
                    completionHandler(Result.success(EmptySuccess()))
                }
            }
        }
    }
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - body: Information about message, format depends of type
    ///   - id: Id of message
    ///   - sender: Id of user which send this message
    ///   - time: Timestamp of message
    ///   - type: Type of message
    required init(body: String, id: String, sender: String, time: Double, type: String) {
        self.body = body
        self.id = id
        self.sender = sender
        self.time = time
        self.type = MessageType(rawValue: type) ?? .txt
    }
}

