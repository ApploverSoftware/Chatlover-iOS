//
//  ConversationsViewController.swift
//  PlateWithMate
//
//  Created by Grzegorz Hudziak on 18/08/2017.
//  Copyright © 2017 applover.pl. All rights reserved.
//

import UIKit
import Firebase

class ConversationsViewController: UIViewController {
    lazy var presenter: ConversationPresenter = {
        let presenter = ConversationPresenter(view: self)
        return presenter
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        navigationItem.title = ChatLayoutManager.Conversations.title
        super.viewDidLoad()
        let cellXib = UINib(nibName: ConversationCell.objectIdentifier, bundle: Bundle.main)
        tableView.register(cellXib, forCellReuseIdentifier: ConversationCell.objectIdentifier)
        tableView.delegate = presenter
        tableView.dataSource = presenter
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        presenter.fetchConversations()
    }
}

// MARK: - ConversationViewProtocol
extension ConversationsViewController: ConversationViewProtocol {
    func needReloadTableView() {
        self.tableView.reloadData()
    }
    
    func showChat(channel conversation: Channel) {
        let chatVC = UIStoryboard(name: nameOfStoryboardWithConversationAndChatController, bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.channel = conversation
        navigationController?.pushViewController(chatVC, animated: true)
    }
}


