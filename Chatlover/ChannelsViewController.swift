//
//  ChannelsViewController.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 11/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit

class ChannelsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        title = "CHANNEL"
        tableView.dataSource = self
        tableView.dataSource = self
    }
}

// MARK: - UITableViewDelegate
extension ChannelsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showChat", sender: nil)
    }
}

// MARK: - UITableViewDataSource
extension ChannelsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let channelCell = tableView.dequeueReusableCell(withIdentifier: ChannelCell.objectIdentifier, for: indexPath) as! ChannelCell
        channelCell.label.text = "Test Channel"
        
        return channelCell
    }
}



