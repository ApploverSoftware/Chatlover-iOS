//
//  ViewController.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 10/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var inputBar: InputAccessoryView!
    
    // Array of messages
    var messages: [Message] = []
    
    // Ref handler for remove observer in case user left the channel
    var refHandler: (handler: UInt, ref: DatabaseReference)!
    
    // Channel which will be observing
    var channel: Channel!
    
    // Height of default inputBar Height
    let barHeight: CGFloat = 50
    
    // Input view for message tapping
    override var inputAccessoryView: UIView? {
        get {
            return self.inputBar
        }
    }
    
    // Show inpuBar
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    // Obser messages
    private func observMessages() {
        refHandler = Message.observMessages(for: channel.id) { [weak self] (result) in
            guard let weakSelf = self else { return }
            switch result {
            case .success(let newMessage):
                // Append only when this is new message
                if !weakSelf.messages.contains(where: { $0.id == newMessage.id }) {
                    weakSelf.messages.insert(newMessage, at: 0)
                    let newPath = IndexPath(row: 0, section: 0)
                    if newMessage.receiverMessage {
                        weakSelf.tableView.insertRows(at: [newPath], with: .right)
                    } else {
                        weakSelf.tableView.insertRows(at: [newPath], with: .left)
                    }
                    weakSelf.tableView.scrollToRow(at: newPath, at: .top, animated: true)
                }
            case .failure: break
            }
        }
    }
    
    private func getAllMessages() {
        Message.getAllMessages(for: channel.id) { [weak self] (result) in
            guard let weakSelf = self else { return }
            switch result {
            case .success(let messages):
                weakSelf.messages = messages.sorted(by: { $0.0.time < $0.1.time }).reversed()
                weakSelf.tableView.reloadData()
                weakSelf.observMessages()
            case .failure: break
            }
        }
    }
    
    func showKeyboard(notification: Notification) {
        guard let keyboardFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let height = keyboardFrame.cgRectValue.height
        tableView.contentInset.top = height
        tableView.scrollIndicatorInsets.top = height
        if messages.count > 0 {
          tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func hideKeyboard(notification: Notification) {
        self.tableView.contentInset.top = self.barHeight
        self.tableView.scrollIndicatorInsets.top = self.barHeight
    }
    
    /// Send message
    ///
    /// Send message by write it to particular channel
    @IBAction func sendMessage(_ sender: UIButton) {
        if let message = inputBar.message {
            Message.send(message: message, channelId: channel.id, completionHandler: { _ in })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = channel.name
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = barHeight
        tableView.dataSource = self
        tableView.contentInset.top = barHeight
        tableView.scrollIndicatorInsets.top = barHeight
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputBar.invalidateIntrinsicContentSize()
        getAllMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.inputBar.backgroundColor = UIColor.clear
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.showKeyboard(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.hideKeyboard(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        refHandler.ref.removeObserver(withHandle: refHandler.handler)
    }
    
    deinit {
        print("Chat deinit")
    }
}

// MARK: - UITableViewDataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        if message.receiverMessage {
            let receiverCell = tableView.dequeueReusableCell(withIdentifier: ReceiverCell.objectIdentifier, for: indexPath) as! ReceiverCell
            receiverCell.message.text = message.body
            receiverCell.time.text = message.timeText
            receiverCell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return receiverCell
        } else {
            let senderCell = tableView.dequeueReusableCell(withIdentifier: SenderCell.objectIdentifier, for: indexPath) as! SenderCell
            senderCell.messageModel = message
            senderCell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return senderCell
        }
    }
}

// MARK: - UITableViewDelegate
extension ChatViewController: UITableViewDelegate {
    
}
