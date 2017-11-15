//
//  InputAccessoryView.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 10/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit

class InputAccessoryView: UIView, UITextViewDelegate {
    @IBOutlet weak var textView: InputTextView!
    @IBOutlet weak var maxHeight: NSLayoutConstraint!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var separatorLine: UIView!
    
    var message: String? {
        get {
            guard textView.text != "" && textView.textColor != ChatLayoutManager.InputAccessoryView.placeHolderColor else {
                return nil
            }
            
            let messageText = textView.text!
            textView.text = ""
            invalidateIntrinsicContentSize()
            return messageText
        }
    }
    
    override var intrinsicContentSize: CGSize {
        // Calculate intrinsicContentSize that will fit all the text
        let textSize = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        // Turn on scrolling if max reached
        if textSize.height >= maxHeight.constant {
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false
        }
        
        return CGSize(width: bounds.width, height: textSize.height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorLine.isHidden = true
        autoresizingMask = .flexibleHeight
        backgroundColor = .clear
        container.backgroundColor = ChatLayoutManager.InputAccessoryView.backgroundColor
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        sendButton.setBackgroundImage(ChatLayoutManager.InputAccessoryView.sendButtonImage, for: .normal)
        locationButton.setBackgroundImage(ChatLayoutManager.InputAccessoryView.locationButtonImage, for: .normal)
        textView.text = ChatLayoutManager.InputAccessoryView.placeHolderText
        textView.textColor = ChatLayoutManager.InputAccessoryView.placeHolderColor
        
        invalidateIntrinsicContentSize()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == ChatLayoutManager.InputAccessoryView.placeHolderColor {
            textView.text = nil
            textView.textColor = ChatLayoutManager.InputAccessoryView.textColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = ChatLayoutManager.InputAccessoryView.placeHolderText
            textView.textColor = ChatLayoutManager.InputAccessoryView.placeHolderColor
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        invalidateIntrinsicContentSize()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
}

