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
    var image: String
    var type: String
    
    init(name: String, text: String, time: String, image: String, type: String) {
        self.name = name
        self.text = text
        self.time = time
        self.image = image
        self.type = type
    }
    

}

func chatMessageToDictionary(chatmessage : chatMessage) -> [String : NSString]{
    return [
        "name": NSString(string: chatmessage.name),
        "text": NSString(string: chatmessage.text),
        "time": NSString(string: chatmessage.time),
        "image": NSString(string: chatmessage.image),
        "type": NSString(string: chatmessage.type)
    ]
}

var chatMessageArray:[chatMessage] = []

var userName = ""
var chan = "Chat"

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, MenuTransitionManagerDelegate, PNObjectEventListener {
    
    @IBOutlet weak var MessageTableView: UITableView!
    
    var kPreferredTextFieldToKeyboardOffset: CGFloat = 70.0
    var keyboardFrame: CGRect = CGRect.nullRect
    var keyboardIsShowing: Bool = false
    @IBOutlet weak var MessageTextField: UITextField!
    
    @IBOutlet var occupancyButton: UIButton!

        
    var menuTransitionManager = MenuTransitionManager()
    
    var introModalDidDisplay = false
    
    var randomNumber = Int(arc4random_uniform(9))

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        
        appDel.client?.addListener(self)
        
        appDel.client?.subscribeToChannels([chan], withPresence: false)
        
        appDel.client?.subscribeToPresenceChannels([chan])
        
        
        self.MessageTextField.delegate = self
        MessageTableView.dataSource = self
        
        self.MessageTableView.separatorStyle = UITableViewCellSeparatorStyle.None

        updateTableview()
        
        showIntroModal()

    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func keyboardWillShow(notification: NSNotification)
    {
        self.keyboardIsShowing = true
        
        if let info = notification.userInfo {
            self.keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            self.arrangeViewOffsetFromKeyboard()
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        self.keyboardIsShowing = false
        
        self.returnViewToInitialFrame()
    }
    
    func arrangeViewOffsetFromKeyboard()
    {
        var theApp: UIApplication = UIApplication.sharedApplication()
        var windowView: UIView? = theApp.delegate!.window!
        
        var textFieldLowerPoint: CGPoint = CGPointMake(self.MessageTextField!.frame.origin.x, self.MessageTextField!.frame.origin.y + self.MessageTextField!.frame.size.height)
        
        var convertedTextFieldLowerPoint: CGPoint = self.view.convertPoint(textFieldLowerPoint, toView: windowView)
        
        var targetTextFieldLowerPoint: CGPoint = CGPointMake(self.MessageTextField!.frame.origin.x, self.keyboardFrame.origin.y - kPreferredTextFieldToKeyboardOffset)
        
        var targetPointOffset: CGFloat = targetTextFieldLowerPoint.y - convertedTextFieldLowerPoint.y
        var adjustedViewFrameCenter: CGPoint = CGPointMake(self.view.center.x, self.view.center.y + targetPointOffset)
        
        UIView.animateWithDuration(0.2, animations:  {
            self.view.center = adjustedViewFrameCenter
        })
    }
    
    func returnViewToInitialFrame()
    {
        var initialViewRect: CGRect = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)
        
        if (!CGRectEqualToRect(initialViewRect, self.view.frame))
        {
            UIView.animateWithDuration(0.2, animations: {
                self.view.frame = initialViewRect
            });
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        if (self.MessageTextField != nil)
        {
            self.MessageTextField?.resignFirstResponder()
            self.MessageTextField = nil
        }
    }
    
    @IBAction func textFieldDidReturn(textField: UITextField!)
    {
        textField.resignFirstResponder()
        self.MessageTextField = nil
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        self.MessageTextField = textField
        
        if(self.keyboardIsShowing)
        {
            self.arrangeViewOffsetFromKeyboard()
        }
    }
    
    func showIntroModal() {
        if (!introModalDidDisplay) {
            
            var loginAlert:UIAlertController = UIAlertController(title: "New User", message: "Please enter your name", preferredStyle: UIAlertControllerStyle.Alert)
            
            loginAlert.addTextFieldWithConfigurationHandler({
                textfield in
                textfield.placeholder = "What is your name?"
            })
            
            loginAlert.addAction(UIAlertAction(title: "Go", style: UIAlertActionStyle.Default, handler: {alertAction in
                    let textFields:NSArray = loginAlert.textFields! as NSArray
                    let usernameTextField:UITextField = textFields.objectAtIndex(0) as! UITextField
                    userName = usernameTextField.text
                    if(userName == ""){
                        self.showIntroModal()
                    }
                    else{
                        self.introModalDidDisplay = true
                    }
                }))

            
            self.presentViewController(loginAlert, animated: true, completion: nil)
        
        }
        
    }


    deinit {
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        
        appDel.client?.removeListener(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = chan
        //chatMessageArray = []
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        appDel.client?.historyForChannel(chan, start: nil, end: nil, includeTimeToken: true, withCompletion: { (result, status) -> Void in
            
            chatMessageArray = self.parseJson(result.data.messages)
            self.updateTableview()
            
        })
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        for subview in self.view.subviews
        {
            if (subview.isKindOfClass(UITextField))
            {
                var textField = subview as! UITextField
                textField.addTarget(self, action: "textFieldDidReturn:", forControlEvents: UIControlEvents.EditingDidEndOnExit)
                
                textField.addTarget(self, action: "textFieldDidBeginEditing:", forControlEvents: UIControlEvents.EditingDidBegin)
                
            }
        }
       
    }
    
    
    func parseJson(anyObj:AnyObject) -> Array<chatMessage>{
        
        var list:Array<chatMessage> = []
        
        if  anyObj is Array<AnyObject> {
            
           // var b:chatMessage = chatMessage()
            
            for jsonMsg in anyObj as! Array<AnyObject>{
                var json = jsonMsg["message"] as! NSDictionary
                if(json["type"] as AnyObject? as? String != "Chat"){ continue }
                println(json["type"] as AnyObject? as? String)
                var nameJson = (json["name"] as AnyObject? as? String) ?? "" // to get rid of null
                var textJson  =  (json["text"]  as AnyObject? as? String) ?? ""
                var timeJson  =  (json["time"]  as AnyObject? as? String) ?? ""
                var imageJson  =  (json["image"]  as AnyObject? as? String) ?? ""
                var typeJson  =  (json["type"]  as AnyObject? as? String) ?? ""
                
                list.append(chatMessage(name: nameJson, text: textJson, time: timeJson, image: imageJson, type: typeJson))
            }
            self.MessageTableView.reloadData()

            
        }
        
        return list
        
    }//func
    
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
            
            
            var pubChat = chatMessage(name: userName, text: MessageTextField.text, time: getTime(), image: String(randomNumber), type: "Chat")

            var newDict = chatMessageToDictionary(pubChat)

            appDel.client?.publish(newDict, toChannel: chan, compressed: true, withCompletion: nil)
            
            MessageTextField.text = nil
            updateTableview()
        }
        
    }
    
    func getTime() -> String{
        let currentDate = NSDate()  //5 -  get the current date
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a" //format style. Browse online to get a format that fits your needs.
        var dateString = dateFormatter.stringFromDate(currentDate)
        
        return dateString
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessageArray.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: TableViewCell = self.MessageTableView.dequeueReusableCellWithIdentifier("Cell") as! TableViewCell
        if(chatMessageArray[indexPath.row].type as String == "Chat"){
            
            if(chatMessageArray[indexPath.row].name == userName){
                cell.messageTextField.textColor = UIColor.blueColor()
                cell.nameLabel.textColor = UIColor.blueColor()
                cell.timeLabel.textColor = UIColor.blueColor()
            }
            
            cell.messageTextField.text = chatMessageArray[indexPath.row].text as String
            cell.nameLabel.text = chatMessageArray[indexPath.row].name as String
            cell.timeLabel.text = chatMessageArray[indexPath.row].time as String
            
            let imageName = "emoji\(chatMessageArray[indexPath.row].image as String).png"
            let newImage = UIImage(named: imageName)
            cell.userImage.image = newImage
            
            
        }
        if(chatMessageArray[indexPath.row].type as String == "Presence"){
            cell.messageTextField.text = ""
            cell.nameLabel.text = chatMessageArray[indexPath.row].text as String
            cell.timeLabel.text = chatMessageArray[indexPath.row].time as String
            
            //let imageName = "emoji\(chatMessageArray[indexPath.row].image as String).png"
            //let newImage = UIImage(named: imageName)
            //cell.userImage.image = newImage
        }
        
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
    

    
    @IBAction func occupancyButtonTapped(sender: AnyObject) {
        
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        let sourceController = segue.sourceViewController as! MenuTableViewController
    }
    
     func dismiss(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let menuTableViewController = segue.destinationViewController as! MenuTableViewController
        menuTableViewController.transitioningDelegate = self.menuTransitionManager
        self.menuTransitionManager.delegate = self
    }
    
    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!, withStatus status: PNErrorStatus!) {
        println("******didReceiveMessage*****")
        
        var stringData  = message.data.message as! NSDictionary
        println(stringData)
        var stringName  = stringData["name"] as! String
        var stringText  = stringData["text"] as! String
        var stringTime  = stringData["time"] as! String
        var stringImage = stringData["image"] as! String
        var stringType  = stringData["type"] as! String



        var newMessage = chatMessage(name: stringName, text: stringText, time: stringTime, image: stringImage, type: stringType)
        
        chatMessageArray.append(newMessage)
        MessageTableView.reloadData()
        
        let numberOfSections = MessageTableView.numberOfSections()
        let numberOfRows = MessageTableView.numberOfRowsInSection(numberOfSections-1)
        
        if numberOfRows > 0 {
            println(numberOfSections)
            let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
            MessageTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }

    }
    
    func client(client: PubNub!, didReceivePresenceEvent event: PNPresenceEventResult!) {
        println("******didReceivePresenceEvent*****")
        println(event.data)
        var occ = event.data.presence.occupancy.stringValue
        occupancyButton.setTitle(occ, forState: .Normal)
        
        var pubChat = chatMessage(name: "", text: "There was a \(event.data.presenceEvent)", time: getTime(), image: " ",type: "Presence")
        
        var newDict = chatMessageToDictionary(pubChat)
        
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        appDel.client?.publish(newDict, toChannel: chan, compressed: true, withCompletion: nil)
        
        
      
    }
    func client(client: PubNub!, didReceiveStatus status: PNSubscribeStatus!) {
        println("status")
    }
    
}

