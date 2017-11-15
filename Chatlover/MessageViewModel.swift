//
//  MessageViewModel.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 17/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit
import MapKit

protocol MessageProtocol: class {
    var type: Message.MessageType { get }
    var body: String { get }
    var id: String { get }
    var sender: String { get }
    var time: Double { get }
    
    init(body: String, id: String, sender: String, time: Double, type: String)
}

class MessageViewModel {
    let message: MessageProtocol
    
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
    
    var location: CLLocationCoordinate2D {
        get {
            let coordinates = message.body.components(separatedBy: "/")
            return CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinates[0])!, longitude: CLLocationDegrees(coordinates[1])!)
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
    
    var type: Message.MessageType {
        get {
            return message.type
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
    
    // Owner of message
    var messageOwner: ChatUser?
    
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


