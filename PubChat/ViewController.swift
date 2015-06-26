//
//  ViewController.swift
//  PubChat
//
//  Created by Justin Platz on 6/25/15.
//  Copyright (c) 2015 ioJP. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, MenuTransitionManagerDelegate{
    

    @IBOutlet var MessageTableView: UITableView!
    
    @IBOutlet weak var MessageTextField: UITextField!
   
    var messages: [String] = ["test","test2","test3"]
    
    var menuTransitionManager = MenuTransitionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"

        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        
        appDel.client?.subscribeToChannels(["demo"], withPresence: false)
        
        //println(appDel.client?.uuid())
        
        appDel.client?.subscribeToPresenceChannels(["demo"])
        

        self.MessageTextField.delegate = self
        MessageTableView.dataSource = self
        updateTableview()

    }
    
    override func viewWillAppear(animated: Bool) {
        updateTableview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    @IBAction func SendClick(sender: AnyObject) {
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        
        var message = MessageTextField.text
        if(message == "") {return}
        else{
            appDel.client?.publish(message, toChannel: "demo", compressed: true, withCompletion: nil)
            MessageTextField.text = nil
            updateTableview()
        }
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: TableViewCell = self.MessageTableView.dequeueReusableCellWithIdentifier("Cell") as! TableViewCell
        cell.messageTextField.text = messages[indexPath.row] as String
        //println(messages[indexPath.row])
        cell.nameLabel.text = "John Doe"
        cell.timeLabel.text = "12:12am"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func updateTableview(){
        self.MessageTableView.reloadData()
        
        if self.MessageTableView.contentSize.height > self.MessageTableView.frame.size.height {
            MessageTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: messages.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    @IBAction func ChannelButtonTapped(sender: AnyObject) {
        
    }
    
    @IBAction func EditButtonTapped(sender: AnyObject) {
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        var myUUID = appDel.client?.uuid() as! String?
        appDel.client?.publish(myUUID, toChannel: "demo", compressed: true, withCompletion: nil)
    }
    
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        let sourceController = segue.sourceViewController as! MenuTableViewController
        self.title = sourceController.currentItem
    }
    
     func dismiss(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let menuTableViewController = segue.destinationViewController as! MenuTableViewController
        menuTableViewController.currentItem = self.title!
        menuTableViewController.transitioningDelegate = self.menuTransitionManager
        self.menuTransitionManager.delegate = self
    }
    
}

