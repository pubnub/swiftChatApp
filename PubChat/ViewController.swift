//
//  ViewController.swift
//  PubChat
//
//  Created by Justin Platz on 6/25/15.
//  Copyright (c) 2015 ioJP. All rights reserved.
//

import UIKit
import Foundation



class chatMessage : NSObject{
    var name: String
    var text: String
    var time: String
    
    init(name: String, text: String, time: String) {
        self.name = name
        self.text = text
        self.time = time
    }
    
    var getName: String{
        return self.name
    }
    var getText: String{
        return self.text
    }
    var getTime: String{
        return self.time
    }
}

func chatMessageToDictionary(chatmessage : chatMessage) -> [String : NSString]{
    return [
        "name": NSString(string: chatmessage.name),
        "text": NSString(string: chatmessage.text),
        "time": NSString(string: chatmessage.time)
    ]
}


class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, MenuTransitionManagerDelegate, PNObjectEventListener {
    
    @IBOutlet weak var MessageTableView: UITableView!
    
    @IBOutlet weak var MessageTextField: UITextField!
    
    

    var userName = "Jonny Doe"
    
    var chatMessageArray:[chatMessage] = []
    
    var menuTransitionManager = MenuTransitionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
                
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        
        appDel.client?.addListener(self)
        
        appDel.client?.subscribeToChannels(["demo"], withPresence: false)
        
        appDel.client?.subscribeToPresenceChannels(["demo"])
        
        self.MessageTextField.delegate = self
        MessageTableView.dataSource = self
        updateTableview()

    }
    
    deinit {
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        
        appDel.client?.removeListener(self)
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
            
            var pubChat = chatMessage(name: userName, text: MessageTextField.text, time: "12:12am")

            var newDict = chatMessageToDictionary(pubChat)

            appDel.client?.publish(newDict, toChannel: "demo", compressed: true, withCompletion: nil)
            
            MessageTextField.text = nil
            updateTableview()
        }
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatMessageArray.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: TableViewCell = self.MessageTableView.dequeueReusableCellWithIdentifier("Cell") as! TableViewCell
        
        cell.messageTextField.text = chatMessageArray[indexPath.row].text as String
        cell.nameLabel.text = chatMessageArray[indexPath.row].name as String
        cell.timeLabel.text = "12:12am"
        //cell.timeLabel.text = chatMessageArray[indexPath.row].time as String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func updateTableview(){
        self.MessageTableView.reloadData()
        
        if self.MessageTableView.contentSize.height > self.MessageTableView.frame.size.height {
            MessageTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: chatMessageArray.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
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
    
    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!, withStatus status: PNErrorStatus!) {
        println("******didReceiveMessage*****")
        
        var stringData = message.data.message as! NSDictionary
        var stringName = stringData["name"] as! String
        var stringText = stringData["text"] as! String
        var stringTime = stringData["time"] as! String

        var newMessage = chatMessage(name: stringName, text: stringText, time: stringTime)
        
        chatMessageArray.append(newMessage)
        if(MessageTableView != nil){
            println("Not nil")
            MessageTableView.reloadData()
        }
        else{
            println("Pretty nil")
        }
    }
    
    func client(client: PubNub!, didReceivePresenceEvent event: PNPresenceEventResult!) {
        println("******didReceivePresenceEvent*****")
        println(event.data)
    
    }
    func client(client: PubNub!, didReceiveStatus status: PNSubscribeStatus!) {
        println("status")
    }
    
}

