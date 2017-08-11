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
    
    var padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
    
    // Create a new PaddingLabel instance programamtically with the desired insets
    required init(padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)) {
        self.padding = padding
        super.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let superSizeThatFits = super.sizeThatFits(size)
        let width = superSizeThatFits.width + padding.left + padding.right
        let heigth = superSizeThatFits.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
}

