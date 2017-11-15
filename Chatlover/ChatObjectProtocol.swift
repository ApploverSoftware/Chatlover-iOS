//
//  ChatObjectProtocol.swift
//  PlateWithMate
//
//  Created by Grzegorz Hudziak on 22/08/2017.
//  Copyright © 2017 applover.pl. All rights reserved.
//

import UIKit

protocol ChatObjectProtocol: class {
    /// Return dictionary representation of Self
    ///
    /// - Returns: [String : Any] with data from Self
    func toDictionary() -> [String : Any]
    
    /// Failable initializer
    ///
    /// Return initializated Self object if can
    /// be create. Otherwise return nil
    ///
    /// - Parameters:
    ///   - dictionary: Dictionary with Self data
    init?(dictionary: [String : Any])
}

extension ChatObjectProtocol where Self: Channel {
    func toDictionary() -> [String : Any] {
        return [:]
    }
    
    init?(dictionary: [String : Any]) {
        guard let id = dictionary["id"] as? String, let name = dictionary["name"] as? String else {
            return nil
        }
        
        self.init(id: id, name: name, users: [], messages: [], picture: nil)
        
        if let usersDict = dictionary["users"] as? [String : Any] { let users = usersDict.flatMap { ChatUser(dictionary: $0.value as! [String : Any]) }; self.users = users }
        if let messagesDict = dictionary["messages"] as? [String : Any] { let messages = messagesDict.flatMap { Message(dictionary: $0.value as! [String : Any]) }; self.messages = messages }
        if let picture = dictionary["picture"] as? String { self.picture = picture }
    }
}

extension ChatObjectProtocol where Self: Message {
    func toDictionary() -> [String : Any] {
        return [
            "body" : body,
            "id" : id,
            "sender" : sender,
            "time" : time,
            "type" : type.rawValue
        ]
    }
    
    init?(dictionary: [String : Any]) {
        guard let body = dictionary["body"] as? String, let id = dictionary["id"] as? String, let sender = dictionary["sender"] as? String, let time = dictionary["time"] as? Double, let type = dictionary["type"] as? String else {
            return nil
        }
        self.init(body: body, id: id, sender: sender, time: time, type: type)
    }
}

extension ChatObjectProtocol where Self: ChatUser {
    func toDictionary() -> [String : Any] {
        var dictionary: [String : Any] = [:]
        
        dictionary["uid"] = uid
        dictionary["name"] = name
        
        if let fcmToken = fcmToken { dictionary["fcmToken"] = fcmToken }
        if let avatar = avatar { dictionary["avatar"] = avatar }
        
        return dictionary
    }
    
    init?(dictionary: [String : Any]) {
        guard let uid = dictionary["uid"] as? String else {
            return nil
        }
        
        guard let name = dictionary["name"] as? String else {
            return nil
        }
        
        self.init(uid: uid, name: name, fcmToken: dictionary["fcmToken"] as? String, avatar: dictionary["avatar"] as? String)
    }
}
