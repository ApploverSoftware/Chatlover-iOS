//
//  ChannelsViewController.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 11/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit
import Firebase

class ChannelsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var channels: [Channel] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        title = "Channels"
        tableView.dataSource = self
        tableView.delegate = self
        fetchChannels()
    }
    
    private func fetchChannels() {
        Channel.fetchChannels { (result) in
            switch result {
            case .success(let channels):
                self.channels = channels
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func addChannel(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "Channel name"
        })
        let confirmAction = UIAlertAction(title: "Create", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            let channelName = alertController.textFields![0].text!
            Channel.createNewChannel(withName: channelName) { _ in self.fetchChannels() }
        })
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            print("Canelled")
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: { _ in })
       
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            InstanceID.instanceID().deleteID(handler: { (error) in
                if error == nil {
                    InstanceID.instanceID().token()
                    self.navigationController?.popViewController(animated: true)
                }
            })
        } catch {
        
        }
    }
}

// MARK: - UITableViewDelegate
extension ChannelsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.isUserInteractionEnabled = false
        let channelToJoin = channels[indexPath.row]
        Channel.joinToChannel(withId: channelToJoin.id) { (result) in
            self.tableView.isUserInteractionEnabled = true
            switch result {
            case .success:
                self.performSegue(withIdentifier: "showChat", sender: ["channelIndex" : indexPath.row])
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dict = sender as? [String : Int], let channelIndex = dict["channelIndex"] else {
            return
        }
        
        let destVC = segue.destination as! ChatViewController
        destVC.channel = channels[channelIndex]
    }
}

// MARK: - UITableViewDataSource
extension ChannelsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let channelCell = tableView.dequeueReusableCell(withIdentifier: ChannelCell.objectIdentifier, for: indexPath) as! ChannelCell
        channelCell.label.text = channels[indexPath.row].name
        
        return channelCell
    }
}



