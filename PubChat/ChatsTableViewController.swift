//
//  ChatsTableViewController.swift
//  
//
//  Created by Justin Platz on 6/26/15.
//
//

import UIKit

class ChatsTableViewController: UITableViewController {
    
    var blogName = String()
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    @IBAction func BackTapped(sender: AnyObject) {
        println("pressed")
        self.dismissViewControllerAnimated(true, completion: nil)

    }
}
