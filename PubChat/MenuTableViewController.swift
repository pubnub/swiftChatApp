//
//  MenuTableViewController.swift
//  SlideMenu
//
//  Created by Simon Ng on 9/2/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    var menuItems = ["Chats", "Change Name", "Settings"]
    var currentItem = "Home"
    let blogSegueIdentifier = "ShowBlogSegue"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return menuItems.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println(menuItems[indexPath.row] as String)
        
        if(indexPath.row == 0){
            performSegueWithIdentifier("ChatPushedSegue", sender: self)

        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MenuTableViewCell

        // Configure the cell...
        cell.titleLabel.text = menuItems[indexPath.row]
        cell.titleLabel.textColor = (menuItems[indexPath.row] == currentItem) ? UIColor.whiteColor() : UIColor.grayColor()
        return cell
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let menuTableViewController = segue.sourceViewController as! MenuTableViewController
        
        let selectedRow = menuTableViewController.tableView.indexPathForSelectedRow()?.row
        
//        if(selectedRow == 0){
//            println("Chats")
//            if (segue.identifier == blogSegueIdentifier){
//                let destination = segue.destinationViewController as? ChatsTableViewController
//                println("Destination is ")
//                println(destination)
//                if ((destination) != nil){
//                    let blogIndex = tableView.indexPathForSelectedRow()?.row
//                    println("blogIndex is")
//                    println(tableView.indexPathForSelectedRow()?.row)
//                    if ((blogIndex) != nil){
//                        destination!.blogName = menuItems[blogIndex!]
//                    }
//                }
//            }
//        }
      
    }
    
    
    
    @IBAction func exitTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});//This is intended to dismiss the Info sceen.
        println("pressed")
    }

    
}
