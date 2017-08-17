//
//  ChatCells.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 10/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit

protocol ObjectIdentifier: class {
    static var objectIdentifier: String { get }
}

extension ObjectIdentifier {
    static var objectIdentifier: String {
        get {
            return "\(Self.self)"
        }
    }
}

class SenderCell: UITableViewCell, ObjectIdentifier {
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageContainer: UIView!

    var messageModel: Message! {
        didSet {
            time.text = messageModel.timeText
            message.text = messageModel.body
            User.info(forUserId: messageModel.sender) { (result) in
                switch result {
                case .success(let user):
                    self.name.text = user.name
                case .failure: break
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageContainer.layer.cornerRadius = ChatLayoutManager.Messages.messageCornerRadius
        messageContainer.backgroundColor = ChatLayoutManager.Messages.senderBackgroundColor
        message.backgroundColor = ChatLayoutManager.Messages.senderBackgroundColor
        message.textColor = ChatLayoutManager.Messages.senderFontColor
        
        if ChatLayoutManager.Messages.senderProfileImageHide {
            userImage.removeFromSuperview()
        }
    }
}

class ReceiverCell: UITableViewCell, ObjectIdentifier {
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageContainer.layer.cornerRadius = ChatLayoutManager.Messages.messageCornerRadius
        messageContainer.backgroundColor = ChatLayoutManager.Messages.receiverBackgroundColor
        message.backgroundColor = ChatLayoutManager.Messages.receiverBackgroundColor
        message.textColor = ChatLayoutManager.Messages.receiverFontColor
    }
}

class DaySeparatorCell: UITableViewCell, ObjectIdentifier {
    @IBOutlet weak var date: UILabel!
    
    var messageModel: Message! {
        didSet {
            date.text = messageModel.separatorTimeText
        }
    }
}
