//
//  ViewController.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 10/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class ChatViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var inputBar: InputAccessoryView!
    
    // Array of messages
    var messages: [MessageViewModel] = []
    
    // Ref handler for remove observer in case user left the channel
    var refHandler: (handler: UInt, ref: DatabaseReference)?
    
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
                let newMessage = MessageViewModel(message: message)
                newMessage.messageOwner = weakSelf.channel.users.findElement({ $0.uid == message.sender })
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
                        let separatorMessage = MessageViewModel(message: Message(body: "", id: "", sender: "", time: newMessage.message.time, type: ""))
                        separatorMessage.separatorCell = true
                        weakSelf.messages.insert(contentsOf: [newMessage, separatorMessage], at: 0)
                        let newMessagePath = IndexPath(row: 1, section: 0)
                        let separatorPath = IndexPath(row: 0, section: 0)
                        weakSelf.insertToTableView(newMesssages: newMessage, at: [separatorPath, newMessagePath])
                    }
                }
                
            case .failure: break
            }
        }
    }
    
    private func insertToTableView(newMesssages: MessageViewModel, at indexPaths: [IndexPath]) {
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
                print(newMessages)
                let messages = newMessages.map { m -> MessageViewModel in
                    let messageModel = MessageViewModel(message: m)
                    messageModel.messageOwner = self?.channel.users.findElement({ $0.uid == m.sender })
                    return messageModel
                }
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
        var separatedMessageArray: [MessageViewModel] = []
        messages.enumerated().forEach { (index, message) in
            // First index
            if index == 0 {
                separatedMessageArray.append(message)
            } else {
                let previousMessage = messages[index - 1]
                if Calendar.current.isDate(previousMessage.date, inSameDayAs: message.date) {
                    separatedMessageArray.append(message)
                } else {
                    let separatorModel = MessageViewModel(message: Message(body: "", id: "", sender: "", time: previousMessage.message.time, type: ""))
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
        if height > 100 {
            tableView.contentInset.top = height
            tableView.scrollIndicatorInsets.top = height
            print(tableView.contentOffset)
            if messages.count > 0 && (tableView.contentOffset.y + self.barHeight) < height {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    func hideKeyboard(notification: Notification) {
        self.tableView.contentInset.top = self.barHeight
        self.tableView.scrollIndicatorInsets.top = self.barHeight
    }
    
    /// Send message as text
    ///
    @IBAction func sendMessage(_ sender: UIButton) {
        if let message = inputBar.message {
            Message.sendTextMessage(message: message, channelId: channel.id, completionHandler: {_ in})
        }
    }
    
    
    /// Send message as location
    ///
    @IBAction func sendLocation(_ sender: UIButton) {
        startAnimateLocationButton(button: sender)
        LocationManager.instance.updateLocation { (location) in
            self.stopAnimateLocationButton(button: sender)
            let lat = "\(location.coordinate.latitude)"
            let long = "\(location.coordinate.longitude)"
            let locationString = lat + "/" + long
            Message.sendLocationMessage(location: locationString, channelId: self.channel.id, completionHandler: {_ in})
        }
    }
    
    /// Start animating send location button
    ///
    /// - Parameter sender: UIButton object
    private func startAnimateLocationButton(button: UIButton) {
        button.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2, delay: 0, options: [.repeat], animations: {
            button.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
        UIView.animate(withDuration: 0.2, delay: 0.2, options: [.repeat], animations: {
            button.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    /// Stop animating send location button
    ///
    /// - Parameter button: UIButton object
    private func stopAnimateLocationButton(button: UIButton) {
        button.isUserInteractionEnabled = true
        button.layer.removeAllAnimations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = channel.name
        
        let bundle = Bundle(for: ChatViewController.self)
        let senderCellXib = UINib(nibName: SenderCell.objectIdentifier, bundle: bundle)
        let receiverCellXib = UINib(nibName: ReceiverCell.objectIdentifier, bundle: bundle)
        let separatorCellXib = UINib(nibName: DaySeparatorCell.objectIdentifier, bundle: bundle)
        tableView.register(senderCellXib, forCellReuseIdentifier: SenderCell.objectIdentifier)
        tableView.register(receiverCellXib, forCellReuseIdentifier: ReceiverCell.objectIdentifier)
        tableView.register(separatorCellXib, forCellReuseIdentifier: DaySeparatorCell.objectIdentifier)

        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = barHeight
        tableView.dataSource = self
        tableView.delegate = self
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
        if let refHandler = refHandler {
            refHandler.ref.removeObserver(withHandle: refHandler.handler)
        }
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
            separatorCell.messageModel = message
            return separatorCell
        } else {
            if message.receiverMessage {
                let receiverCell = tableView.dequeueReusableCell(withIdentifier: ReceiverCell.objectIdentifier, for: indexPath) as! ReceiverCell
                receiverCell.messageModel = message
                return receiverCell
            } else {
                let senderCell = tableView.dequeueReusableCell(withIdentifier: SenderCell.objectIdentifier, for: indexPath) as! SenderCell
                senderCell.messageModel = message
                return senderCell
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        inputBar.textView.resignFirstResponder()
        let message = messages[indexPath.row]
        if message.type == .loc {
            openMapForPlace(message: message)
        }
    }
    
    private func openMapForPlace(message: MessageViewModel) {
        let location = message.location
        let regionDistance: CLLocationDistance = 10000
        let regionSpan = MKCoordinateRegionMakeWithDistance(location, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: location)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = message.receiverMessage ? ChatLayoutManager.Other.externalMapMyPinTitle : "\(ChatLayoutManager.Other.externalMapUserPinTtitle) \(message.messageOwner!.name)"
        mapItem.openInMaps(launchOptions: options)
    }
}

