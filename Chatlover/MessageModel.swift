//
//  MessageModel.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 17/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit

protocol MessageProtocol: class {
    var body: String { get }
    var id: String { get }
    var sender: String { get }
    var time: Int { get }
    
    init(body: String, id: String, sender: String, time: Int)
}

class MessageModel {
    unowned let message: MessageProtocol
    
    // Date from timestamp
    var date: Date {
        get {
            return Date(timeIntervalSince1970: Double(message.time / 1000))
        }
    }
    
    // Owner id
    var ownerId: String {
        get {
            return message.id
        }
    }
    
    // Message text
    var messageText: String {
        get {
            return message.body
        }
    }
    
    // True if message belongs to current logged user
    var receiverMessage: Bool {
        get {
            return ChatUser.currentUser!.uid == message.sender
        }
    }
    
    // Text to show as date text in every message cell
    var timeText: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE HH:mm"
            return formatter.string(from: date)
        }
    }
    
    // True when message is separator
    var separatorCell: Bool = false
    
    // Text to show as day text in day separator cell
    var separatorTimeText: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE dd.MM"
            return formatter.string(from: date)
        }
    }
    
    /// Initializer
    ///
    /// - Parameter message: Object which conform to MessageProtocol
    init(message: MessageProtocol) {
        self.message = message
    }
}
