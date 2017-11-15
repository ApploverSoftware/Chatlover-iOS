//
//  RoundedImageView.swift
//  Chatlover
//
//  Created by Mac on 07.11.2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit

class RoundedImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = true
        self.layer.borderWidth = 2
        self.contentMode = .scaleAspectFill
    }
}
