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

    // First scroll to bottom when user opened chat
    var scrollToBottomAtStat: Bool = false
    
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
                let newPath = IndexPath(row: weakSelf.messages.count, section: 0)
                weakSelf.messages.append(newMessage)
                weakSelf.tableView.reloadData()
                if newMessage.receiverMessage {
                    weakSelf.tableView.insertRows(at: [newPath], with: .right)
                } else {
                    weakSelf.tableView.insertRows(at: [newPath], with: .left)
                }
            case .failure: break
            }
        }
    }
    
    func showKeyboard(notification: Notification) {
        guard let keyboardFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let height = keyboardFrame.cgRectValue.height
        tableView.contentInset.bottom = height
        tableView.scrollIndicatorInsets.bottom = height
        if messages.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func hideKeyboard(notification: Notification) {
        guard let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        UIView.animate(withDuration: duration) {
            self.tableView.contentInset.bottom = self.barHeight
            self.tableView.scrollIndicatorInsets.bottom = self.barHeight
        }
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
        tableView.contentInset.bottom = barHeight
        tableView.scrollIndicatorInsets.bottom = barHeight
        observMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputBar.invalidateIntrinsicContentSize()
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
            return receiverCell
        } else {
            let senderCell = tableView.dequeueReusableCell(withIdentifier: SenderCell.objectIdentifier, for: indexPath) as! SenderCell
            senderCell.messageModel = message
            return senderCell
        }
    }
}

// MARK: - UITableViewDelegate
extension ChatViewController: UITableViewDelegate {
    
}
