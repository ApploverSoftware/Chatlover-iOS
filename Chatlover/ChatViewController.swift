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
    var messages: [MessageModel] = []
    
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
    
    // Observ new messages messages
    private func observMessages() {
        refHandler = Message.observMessages(for: channel.id) { [weak self] (result) in
            guard let weakSelf = self else { return }
            switch result {
            case .success(let message):
                let newMessage = MessageModel(message: message)
                // Append only when this is new message
                guard !weakSelf.messages.contains(where: { $0.message.id == newMessage.message.id }) else {
                    return
                }
                
                // Check if messages array is empty
                if weakSelf.messages.isEmpty {
                    weakSelf.messages.insert(newMessage, at: 0)
                    let newPath = IndexPath(row: 0, section: 0)
                    weakSelf.insertToTableView(newMesssages: newMessage, at: [newPath])
                } else {
                    // Check if message date is in same day as previous
                    if Calendar.current.isDate(newMessage.date, inSameDayAs: weakSelf.messages.first!.date) {
                        weakSelf.messages.insert(newMessage, at: 0)
                        let newPath = IndexPath(row: 0, section: 0)
                        weakSelf.insertToTableView(newMesssages: newMessage, at: [newPath])
                    } else { // Insert day separator model before new cell model
                        let separatorMessage = MessageModel(message: Message(body: "", id: "", sender: "", time: newMessage.message.time))
                        separatorMessage.separatorCell = true
                        weakSelf.messages.insert(contentsOf: [separatorMessage, newMessage], at: 0)
                        let separatorPath = IndexPath(row: 0, section: 0)
                        let newMessagePath = IndexPath(row: 1, section: 0)
                        weakSelf.insertToTableView(newMesssages: newMessage, at: [separatorPath, newMessagePath])
                    }
                }
                
            case .failure: break
            }
        }
    }
    
    private func insertToTableView(newMesssages: MessageModel, at indexPaths: [IndexPath]) {
        if newMesssages.receiverMessage {
            tableView.insertRows(at: indexPaths, with: .right)
        } else {
            tableView.insertRows(at: indexPaths, with: .left)
        }
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    private func getAllMessages() {
        Message.getAllMessages(for: channel.id) { [weak self] (result) in
            guard let weakSelf = self else { return }
            switch result {
            case .success(let newMessages):
                let messages = newMessages.map { MessageModel(message: $0) }
                // Reversed because tableView is rotated by 180 degree
                weakSelf.messages = messages.reversed()
                if ChatLayoutManager.ChatTableView.daySeparator {
                    weakSelf.insertSeparators()
                }
                weakSelf.tableView.reloadData()
                weakSelf.observMessages()
            case .failure: break
            }
        }
    }
    
    
    /// Function insert separator model as message with separatorCell 
    /// property seting to true seaprator model is for showing day 
    /// separator cell with day name + date in format: --- EEEE dd.MM ---
    private func insertSeparators() {
        var separatedMessageArray: [MessageModel] = []
        messages.enumerated().forEach { (index, message) in
            // First index
            if index == 0 {
                separatedMessageArray.append(message)
            } else {
                let previousMessage = messages[index - 1]
                if Calendar.current.isDate(previousMessage.date, inSameDayAs: message.date) {
                    separatedMessageArray.append(message)
                } else {
                    let separatorModel = MessageModel(message: Message(body: "", id: "", sender: "", time: previousMessage.message.time))
                    separatorModel.separatorCell = true
                    separatedMessageArray.append(separatorModel)
                    separatedMessageArray.append(message)
                }
            }
        }
        messages = separatedMessageArray
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
        getAllMessages()
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
        if message.separatorCell {
            let separatorCell = tableView.dequeueReusableCell(withIdentifier: DaySeparatorCell.objectIdentifier, for: indexPath) as! DaySeparatorCell
            separatorCell.date.text = message.separatorTimeText
            separatorCell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return separatorCell
        } else {
            if message.receiverMessage {
                let receiverCell = tableView.dequeueReusableCell(withIdentifier: ReceiverCell.objectIdentifier, for: indexPath) as! ReceiverCell
                receiverCell.message.text = message.messageText
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
}

// MARK: - UITableViewDelegate
extension ChatViewController: UITableViewDelegate {
    
}
