//
//  ConversationPresenter.swift
//  PlateWithMate
//
//  Created by Grzegorz Hudziak on 21/08/2017.
//  Copyright © 2017 applover.pl. All rights reserved.
//

import UIKit

protocol ConversationViewProtocol: class {
    func needReloadTableView()
    func showChat(channel: Channel)
}

class ConversationPresenter: NSObject {
    weak var view: ConversationViewProtocol?
    
    var conversations: [Channel] = [] {
        didSet {
            self.view?.needReloadTableView()
        }
    }
    
    init(view: ConversationViewProtocol) {
        self.view = view
    }
    
    func fetchConversations() {
        ChatUser.currentUser!.fetchChannels(completionHandler: { (result) in
            switch result {
            case .success(let conversations):
                self.conversations = conversations
                self.view?.needReloadTableView()
            case .failure(let error):
                BasicAlert.showInfoAlert(with: error)
            }
        })
    }
}

// MARK: - UITableViewDataSource
extension ConversationPresenter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = conversations[indexPath.row]
        view?.showChat(channel: conversation)
    }
}

// MARK: - UITableViewDelegate
extension ConversationPresenter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let conversationCell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.objectIdentifier, for: indexPath) as! ConversationCell
        conversationCell.model = conversations[indexPath.row]
        return conversationCell
    }
}


