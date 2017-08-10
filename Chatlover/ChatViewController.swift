//
//  ViewController.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 10/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var inputBar: InputAccessoryView!
    
    override var inputAccessoryView: UIView? {
        get {
            return self.inputBar
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
}

