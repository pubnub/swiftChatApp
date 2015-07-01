//
//  MenuTableViewController.swift
//  SlideMenu
//
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
        
        
        if(segue.identifier == "ShowBlogSegue"){
            println("VIEW SEG")
        }
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
                userName = userName.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
                if(userName == ""){
                    self.showNameModal()
                }
                else{
                    println("******changing UUID to \(userName)")
                    nameChanged = true
                }
            }))
        
            self.presentViewController(loginAlert, animated: true, completion: nil)
    }
    
    
    func showChannelModal() {
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        appDel.client?.unsubscribeFromChannels([chan],withPresence: true)

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
                self.showChannelModal()
            }
            else{
                chatMessageArray = []
                usersArray = []
                //appDel.client?.subscribeToChannels([chan], withPresence: true)
            }
        }))
        
        self.presentViewController(loginAlert, animated: true, completion: nil)
    }
    
    
    
}
