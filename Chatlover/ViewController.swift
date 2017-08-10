//
//  ViewController.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 10/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSideUserCell = UINib(nibName: "LeftSideUserCell", bundle: nil)
        tableView.register(leftSideUserCell, forCellReuseIdentifier: "LeftSideUserCell")
        
        let rightSideUserCell = UINib(nibName: "RightSideUserCell", bundle: nil)
        tableView.register(rightSideUserCell, forCellReuseIdentifier: "RightSideUserCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

