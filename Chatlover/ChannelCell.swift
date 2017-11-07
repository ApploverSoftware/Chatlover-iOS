//
//  ConversationCell.swift
//  PlateWithMate
//
//  Created by Grzegorz Hudziak on 21/08/2017.
//  Copyright © 2017 applover.pl. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell, CellIdentifier {
    @IBOutlet weak var avatar: RoundedImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var channelName: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var separatorLine: UIView!
    
    var model: Channel! {
        didSet {
            let friend = model.users.filter { $0.uid != ChatUser.currentUser!.uid }.first!
            name.text = friend.name.uppercased()
            channelName.text = model.name
            if let lastMessageObj = model.messages.first {
                let messageModel = MessageViewModel(message: lastMessageObj)
                time.text = messageModel.timeText
                switch messageModel.type {
                case .txt:
                    self.lastMessage.text = messageModel.messageText
                case .loc:
                    GoogleAPIProvider.getAddress(from: messageModel.location) { result in
                        switch result {
                        case .success(let locationText):
                            self.lastMessage.text = locationText
                        case .failure(let error):
                            self.lastMessage.text = error.localizedDescription
                        }
                    }
                default: break
                }
            }
            friend.getProfilePic { (image) in
                self.avatar.image = image
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clearContent()
        
        name.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
        
        channelName.font = UIFont.systemFont(ofSize: 14)
        channelName.textColor = UIColor.darkGray
        
        lastMessage.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        lastMessage.textColor = UIColor.darkGray
        
        time.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        time.textColor = UIColor.darkGray
        
        separatorLine.backgroundColor = UIColor.gray
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearContent()
    }
    
    private func clearContent() {
        avatar.image = UIImage(named: "google")
        name.text = NSLocalizedString("_cellDownloadingText", comment: "")
        lastMessage.text = ""
        time.text = ""
    }
}

