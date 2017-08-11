//
//  InputTextView.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 10/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit

class InputTextView: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = ChatLayoutManager.InputAccessoryView.cornerRadius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        self.layer.borderWidth = ChatLayoutManager.InputAccessoryView.borderWidth
        self.layer.borderColor = ChatLayoutManager.InputAccessoryView.borderColor.cgColor
        self.textContainerInset = ChatLayoutManager.InputAccessoryView.textContainerInset
    }
}

class MessageLabel: UILabel {
    
    var padding = ChatLayoutManager.Messages.textPadding
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = ChatLayoutManager.Messages.messageCornerRadius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, padding))
    }
    
    override var intrinsicContentSize: CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let height = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: height)
    }
}

