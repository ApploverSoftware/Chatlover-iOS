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

