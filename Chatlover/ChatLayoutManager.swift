//
//  ChatLayoutManager.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 10/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit

let nameOfStoryboardWithConversationAndChatController = "Chat"

final public class ChatLayoutManager {
    public struct InputAccessoryOption : OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let location = InputAccessoryOption(rawValue: 1 << 0)
        public static let images = InputAccessoryOption(rawValue: 1 << 1)
        public static let video = InputAccessoryOption(rawValue: 1 << 2)
        public static let voice = InputAccessoryOption(rawValue: 1 << 3)
    }
    
    
    struct InputAccessoryView {
        static var cornerRadius: CGFloat = 18
        static var borderWidth: CGFloat = 1
        static var borderColor: UIColor = UIColor.orange
        static var backgroundColor: UIColor = UIColor.white
        static var textContainerInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        static var sendButtonImage: UIImage = UIImage(named: "sendImage")!
        static var locationButtonImage: UIImage = UIImage(named: "sendLocation")!
        static var placeHolderColor: UIColor = UIColor.lightGray
        static var textColor: UIColor = UIColor.darkGray
        static var placeHolderText: String = "Tap message..."
        static var sendingOptions: InputAccessoryOption = [.location]
    }
    
    struct Messages {
        // Base
        static var messageCornerRadius: CGFloat = 0
        static var messageNameTimeColor: UIColor = UIColor.darkGray.withAlphaComponent(0.5)
        static var messageTextFont = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
        static var messageTimeFont = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
        static var locationMessageImage = UIImage(named: "localization")!
        static var defaultImage = UIImage(named: "userDefaultImage")!
        static var locationMessageDownloadText: String = "Downloading..."

        // Location type
        static var messageLocationHeaderFont = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        
        // Separator
        static var messageSeparatorFont = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
        static var messageSeparatorTextColor = Messages.messageNameTimeColor
        
        // Receiver
        static var receiverNameFont = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
        static var receiverBackgroundColor: UIColor = UIColor.gray
        static var receiverFontColor: UIColor = UIColor.darkGray
        static var receiverLocationHeader: String = "You shared your location!"
        
        // Sender
        static var senderBackgroundColor: UIColor = UIColor.orange
        static var senderFontColor: UIColor = UIColor.darkGray
        static var senderProfileImageHide: Bool = false
        static var senderLocationHeader: String = "User shared his location!"
    }
    
    struct Other {
        static var externalMapMyPinTitle: String = "My localization"
        static var externalMapUserPinTtitle: String = "Localization of"
    }
    
    struct Conversations {
        static var title: String = "Conversations"
        static var downloadCellContentText: String = "Downloading..."
    }
    
    struct ChatTableView {
        static var daySeparator: Bool = true
    }
}

