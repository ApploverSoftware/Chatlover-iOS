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
    
    var message: String? {
        get {
            guard textView.text != "" else {
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
        autoresizingMask = .flexibleHeight
        backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
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
