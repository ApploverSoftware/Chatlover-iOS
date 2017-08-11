//
//  ChatCells.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 10/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit

protocol ObjectIdentifier: class {
    static var objectIdentifier: String { get }
}

extension ObjectIdentifier {
    static var objectIdentifier: String {
        get {
            return "\(Self.self)"
        }
    }
}

class SenderCell: UITableViewCell, ObjectIdentifier {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var message: MessageLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.black.cgColor
        message.backgroundColor = UIColor.green
    }
}

class ReceiverCell: UITableViewCell, ObjectIdentifier {
    @IBOutlet weak var message: MessageLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.black.cgColor
        message.backgroundColor = UIColor.red
    }
}
