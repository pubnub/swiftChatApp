//
//  MenuTableViewController.swift
//  SlideMenu
//
//  Created by Simon Ng on 9/2/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    var menuItems = ["Change Channel", "Change Name"]
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
            //performSegueWithIdentifier("ChatPushedSegue", sender: self)
            showChannelModal()
        }
        
        if(indexPath.row == 1){
            showNameModal()
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MenuTableViewCell

        // Configure the cell...
        cell.titleLabel.text = menuItems[indexPath.row]
        return cell
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let menuTableViewController = segue.sourceViewController as! MenuTableViewController
        
        let selectedRow = menuTableViewController.tableView.indexPathForSelectedRow()?.row
      
    }
    
    func showNameModal() {
        
            var loginAlert:UIAlertController = UIAlertController(title: "Change Name", message: "Please enter your new name", preferredStyle: UIAlertControllerStyle.Alert)
            
            loginAlert.addTextFieldWithConfigurationHandler({
                textfield in
                textfield.placeholder = "What is your name?"
            })
            
            loginAlert.addAction(UIAlertAction(title: "Go", style: UIAlertActionStyle.Default, handler: {alertAction in
                let textFields:NSArray = loginAlert.textFields! as NSArray
                let usernameTextField:UITextField = textFields.objectAtIndex(0) as! UITextField
                userName = usernameTextField.text
                if(userName == ""){
                    self.showNameModal()
                }
                else{
                    
                }
            }))
        
            self.presentViewController(loginAlert, animated: true, completion: nil)
    }
    
    
    
    func showChannelModal() {
        
        var loginAlert:UIAlertController = UIAlertController(title: "Change Channel", message: "Please enter Channel name", preferredStyle: UIAlertControllerStyle.Alert)
        
        loginAlert.addTextFieldWithConfigurationHandler({
            textfield in
            textfield.placeholder = "Subscribe me to channel: _____"
        })
        
        loginAlert.addAction(UIAlertAction(title: "Go", style: UIAlertActionStyle.Default, handler: {alertAction in
            let textFields:NSArray = loginAlert.textFields! as NSArray
            let usernameTextField:UITextField = textFields.objectAtIndex(0) as! UITextField
            chan = usernameTextField.text
            if(chan == ""){
                //self.showChannelModal()
            }
            else{
                let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
                appDel.client?.unsubscribeFromChannels([],withPresence: true)
                appDel.client?.unsubscribeFromPresenceChannels([])
                chatMessageArray = []
                appDel.client?.subscribeToChannels([chan], withPresence: false)
                appDel.client?.subscribeToPresenceChannels([chan])
            }
        }))
        
        self.presentViewController(loginAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func exitTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});//This is intended to dismiss the Info sceen.
        println("pressed")
    }

    
}
