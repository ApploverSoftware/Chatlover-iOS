//
//  ViewController.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 10/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit

enum MessageType: String {
    case receiver
    case sender
}

class Message {
    var messageText: String
    var type: MessageType
    var userImagePath: String
    
    init(messageText: String, type: MessageType, userImagePath: String) {
        self.messageText = messageText
        self.type = type
        self.userImagePath = userImagePath
    }
}

let fakeData = [
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .receiver, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota Ale ma kota Ale ma kota Ale ma kota", type: .receiver, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .receiver, userImagePath: ""),
    Message(messageText: "Ale ma kota Ale ma kota Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .receiver, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
    Message(messageText: "Ale ma kota", type: .sender, userImagePath: ""),
]

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.showKeyboard(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Keyboard handler
    func showKeyboard(notification: Notification) {
        if let keyboardFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let height = keyboardFrame.cgRectValue.height
            tableView.contentInset.bottom = height
            tableView.scrollIndicatorInsets.bottom = height
            if fakeData.count > 0 {
                let indexPathToScroll = IndexPath(row: fakeData.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPathToScroll, at: .bottom, animated: true)
            }
        }
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
    }
}

// MARK: - UITableViewDataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fakeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = fakeData[indexPath.row]
        
        switch message.type {
        case .receiver:
            let receiverCell = tableView.dequeueReusableCell(withIdentifier: ReceiverCell.objectIdentifier, for: indexPath) as! ReceiverCell
            receiverCell.message.text = message.messageText
            return receiverCell
        case .sender:
            let senderCell = tableView.dequeueReusableCell(withIdentifier: SenderCell.objectIdentifier, for: indexPath) as! SenderCell
            senderCell.message.text = message.messageText
            return senderCell
        }
    }
}
