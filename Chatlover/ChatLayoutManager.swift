//
//  ChatLayoutManager.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 10/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit

class ChatLayoutManager {
    struct InputAccessoryView {
        static var cornerRadius: CGFloat = 13
        static var borderWidth: CGFloat = 0.5
        static var borderColor: UIColor = UIColor.gray
        static var textContainerInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    struct Messages {
        static var messageCornerRadius: CGFloat = 16
        static var textPadding: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        static var receiverBackgroundColor: UIColor = UIColor.red.withAlphaComponent(0.5)
        static var receiverFontColor: UIColor = UIColor.black

        static var senderBackgroundColor: UIColor = UIColor.green.withAlphaComponent(0.5)
        static var senderFontColor: UIColor = UIColor.black
    }
}
