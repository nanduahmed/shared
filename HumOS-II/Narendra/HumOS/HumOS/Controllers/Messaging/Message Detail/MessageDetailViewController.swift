//
//  MessageDetailViewController.swift
//  HumOS
//
//  Created by Deepesh.Sunku on 9/1/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import UIKit

class MessageDetailViewController: UIViewController,PubNubDelagate {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var textFieldUIView: UIView!
    
    var otherUserId:String?
    var detailMsgModel:DetailMessageModel?
    
    var kbHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.keyboardDismissMode = .Interactive
        
        navigationController!.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        tabBarController?.tabBar.hidden = true
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        
        self.downloadMessage()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MessageDetailViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MessageDetailViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        PubNubHandler.sharedManager.delegate = self

    }
    
    
    func downloadMessage()  {
        HumOSObjectModelFactory.sharedManager.getObjectOfType(HumOSObjectType.DownloadMessageObj, parameters: ["to_uid":otherUserId!]) { (obj) in
            print(obj)
            self.detailMsgModel = obj as? DetailMessageModel
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
            })
        }
    }
    

    
    func saveMessage(message: Message){
        if let toUID = otherUserId, let accessToken = HumOSObjectModelFactory.sharedManager.accessToken,
            let senderName = HumOSObjectModelFactory.sharedManager.loginObject?.user?.attributes.fullName{
            
            let payload = message.JSON(accessToken, sendername: senderName, toUID: toUID)
            HumOSObjectModelFactory.sharedManager.getObjectOfType(HumOSObjectType.CreateMessage, parameters: payload) { (obj) in
                print(obj)
                if (obj.success == true) {
                    PubNubHandler.sharedManager.publishMessageOnChannel(message.getPubNubMessage(), channel:self.otherUserId)
                }
            }

        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // Handle sending messages here
    @IBAction func sendButton(sender: AnyObject) {
        let msg = Message.init(msg: self.messageTextField.text!)
        self.detailMsgModel?.messages.append(msg)
        let ip = NSIndexPath.init(forRow: ((self.detailMsgModel?.messages.count)!-1), inSection: 0)
        self.tableView.insertRowsAtIndexPaths([ip], withRowAnimation: UITableViewRowAnimation.Automatic)
        messageTextField.text = " "
        saveMessage(msg)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let messages:[Message] = self.detailMsgModel?.messages {
            return messages.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let msg = self.detailMsgModel?.messages[indexPath.row] {
            if(msg.sendFrom == SendFromType.me) {
                let cell = tableView.dequeueReusableCellWithIdentifier("ToMessageCell") as! ToMessageTableViewCell
                if msg.messageType == .text {
                    cell.message.text = msg.text
                } else if msg.messageType == .image {
                    cell.message.text = "Image Message under dev"
                } else {
                    cell.message.text = "Video Message under dev"
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("FromMessageCell") as! FromMessageTableViewCell
                cell.message.text = msg.text
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ToMessageCell") as! ToMessageTableViewCell
            cell.message.text = "No Messages"
            return cell
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height
                self.animateTextField(true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.animateTextField(false)
    }
    
    func animateTextField(up: Bool) {
        let movement = (up ? +(kbHeight) : (0))
        self.bottomConstraint.constant = movement
        UIView.animateWithDuration(0.3, animations: {
            self.backgroundView.layoutIfNeeded()
        })
        
    }
    func didReceiveMessage(message: AnyObject) {
        downloadMessage()
    }

}
