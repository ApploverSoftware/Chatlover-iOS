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
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var message: MessageLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        message.adjustsFontSizeToFitWidth = true
        message.translatesAutoresizingMaskIntoConstraints = false
        message.backgroundColor = UIColor.green
    }
}

class ReceiverCell: UITableViewCell, ObjectIdentifier {
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var message: MessageLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        message.adjustsFontSizeToFitWidth = true
        message.translatesAutoresizingMaskIntoConstraints = false
        message.backgroundColor = UIColor.red
    }
}
