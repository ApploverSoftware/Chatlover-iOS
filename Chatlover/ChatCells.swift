//
//  ChatCells.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 10/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit

protocol CellIdentifier: class {
    static var objectIdentifier: String { get }
}

extension CellIdentifier {
    static var objectIdentifier: String {
        get {
            return "\(Self.self)"
        }
    }
}

class SenderCell: UITableViewCell, CellIdentifier {
    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    // Main container
    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var message: UITextView!
    
    // For location content
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationDescription: UILabel!
    
    var messageModel: MessageViewModel! {
        didSet {
            if !ChatLayoutManager.Messages.senderProfileImageHide {
                messageModel.messageOwner?.getProfilePic(completionHandler: { (image) in
                    self.userImage.image = image
                })
            }
            time.text = messageModel.timeText
            name.text = messageModel.messageOwner?.name.uppercased()
            
            switch messageModel.type {
            case .txt:
                assignAndShowTextContent()
            case .loc:
                assignAndShowLocationContent()
            default: break
            }
        }
    }
    
    private func assignAndShowLocationContent() {
        message.text = ""
        locationTitle.text = ChatLayoutManager.Messages.senderLocationHeader
        locationImageView.image = ChatLayoutManager.Messages.locationMessageImage
        locationDescription.text = ChatLayoutManager.Messages.locationMessageDownloadText
        LocationManager.getAddress(location: messageModel.location) { (result) in
            self.locationDescription.text = result
        }
    }
    
    private func assignAndShowTextContent() {
        message.text = messageModel.messageText
        locationImageView.image = nil
        locationTitle.text = ""
        locationDescription.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        transform = CGAffineTransform(scaleX: 1, y: -1)
        
        time.textColor = ChatLayoutManager.Messages.messageNameTimeColor
        time.font = ChatLayoutManager.Messages.messageTimeFont
        
        name.textColor = ChatLayoutManager.Messages.messageNameTimeColor
        name.font = ChatLayoutManager.Messages.receiverNameFont
        
        locationTitle.textColor = ChatLayoutManager.Messages.receiverFontColor
        locationTitle.font = ChatLayoutManager.Messages.messageLocationHeaderFont
        
        locationDescription.textColor = ChatLayoutManager.Messages.receiverFontColor
        locationDescription.font = ChatLayoutManager.Messages.messageTextFont
        
        messageContainer.layer.cornerRadius = ChatLayoutManager.Messages.messageCornerRadius
        messageContainer.backgroundColor = ChatLayoutManager.Messages.senderBackgroundColor
        
        message.backgroundColor = ChatLayoutManager.Messages.senderBackgroundColor
        message.textColor = ChatLayoutManager.Messages.senderFontColor
        message.font = ChatLayoutManager.Messages.messageTextFont
        
        if ChatLayoutManager.Messages.senderProfileImageHide {
            userImage.removeFromSuperview()
        }
    }
}

class ReceiverCell: UITableViewCell, CellIdentifier {
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageContainer: UIView!
    
    // For location content
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationHeader: UILabel!
    @IBOutlet weak var locationDescription: UILabel!
    
    var messageModel: MessageViewModel! {
        didSet {
            time.text = messageModel.timeText
            switch messageModel.type {
            case .txt:
                assignAndShowTextContent()
            case .loc:
                assignAndShowLocationContent()
            default: break
            }
        }
    }
    
    private func assignAndShowLocationContent() {
        message.text = ""
        locationImageView.image = ChatLayoutManager.Messages.locationMessageImage
        locationHeader.text = ChatLayoutManager.Messages.receiverLocationHeader
        locationDescription.text = ChatLayoutManager.Messages.locationMessageDownloadText
        LocationManager.getAddress(location: messageModel.location) { (result) in
            self.locationDescription.text = result
        }
    }
    
    private func assignAndShowTextContent() {
        message.text = messageModel.messageText
        locationImageView.image = nil
        locationHeader.text = ""
        locationDescription.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        transform = CGAffineTransform(scaleX: 1, y: -1)
        
        time.textColor = ChatLayoutManager.Messages.messageNameTimeColor
        time.font = ChatLayoutManager.Messages.messageTimeFont
        
        locationHeader.textColor = ChatLayoutManager.Messages.receiverFontColor
        locationHeader.font = ChatLayoutManager.Messages.messageLocationHeaderFont
        
        locationDescription.textColor = ChatLayoutManager.Messages.receiverFontColor
        locationDescription.font = ChatLayoutManager.Messages.messageTextFont
        
        messageContainer.layer.cornerRadius = ChatLayoutManager.Messages.messageCornerRadius
        messageContainer.backgroundColor = ChatLayoutManager.Messages.receiverBackgroundColor
        
        message.backgroundColor = ChatLayoutManager.Messages.receiverBackgroundColor
        message.textColor = ChatLayoutManager.Messages.receiverFontColor
        message.font = ChatLayoutManager.Messages.messageTextFont
    }
}

class DaySeparatorCell: UITableViewCell, CellIdentifier {
    @IBOutlet weak var leftLine: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var rightLine: UIView!
    
    var messageModel: MessageViewModel! {
        didSet {
            date.text = messageModel.separatorTimeText
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        date.font = ChatLayoutManager.Messages.messageSeparatorFont
        date.textColor = ChatLayoutManager.Messages.messageSeparatorTextColor
        
        leftLine.backgroundColor = ChatLayoutManager.Messages.messageSeparatorTextColor
        rightLine.backgroundColor = ChatLayoutManager.Messages.messageSeparatorTextColor
        
        transform = CGAffineTransform(scaleX: 1, y: -1)
    }
}

