//
//  LoginViewController.swift
//  HumOS
//
//  Created by Deepesh.Sunku on 8/30/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userPhoneNumber: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var outerCircle: UIView!
    @IBOutlet weak var middleCircle: UIView!
    @IBOutlet weak var innerCircle: UIView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let kMinUserNameFieldCount = 3
    let kMinPasswdFieldCount = 0
    
    var textOrginalColor:UIColor?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerForKeyboardNotifications()
        self.scrollView.keyboardDismissMode = .Interactive
        
        // Mark: Section for adding Borders for views and rounding views
        userPhoneNumber.layer.borderWidth = 1.0
        userPhoneNumber.layer.cornerRadius = 5
        userPhoneNumber.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
        
        userPassword.layer.borderWidth = 1.0
        userPassword.layer.cornerRadius = 5
        userPassword.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
        
        outerCircle.layer.borderWidth = 1.0
        outerCircle.layer.cornerRadius = outerCircle.frame.width/2
        outerCircle.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2).CGColor
        
        middleCircle.layer.borderWidth = 1.0
        middleCircle.layer.cornerRadius = middleCircle.frame.width/2
        middleCircle.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4).CGColor
        
        innerCircle.layer.borderWidth = 1.0
        innerCircle.layer.cornerRadius = innerCircle.frame.width/2
        innerCircle.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8).CGColor
        
        iconView.layer.cornerRadius = iconView.frame.width/2
        self.hideActivity(true)
        
        self.textOrginalColor = self.userPhoneNumber.textColor
        self.populateCredsForDev()
    }
    
    func populateCredsForDev()  {
//        self.userPhoneNumber.text = "4085554019"
//        self.userPassword.text = "s"
        
        self.userPhoneNumber.text = "4087778990"
        self.userPassword.text = "s"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // Mark: User Action Functions
    
    @IBAction func closeButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func loginButton(sender: AnyObject) {
        
        /*let payload = ["username":"4085554019",
         "password":"s",
         "type":"android",
         "token":"APA91bF0d4ffOB8q7xjDtFraC_5gv4w3EgvnwCdY34H7_yitLr-UdecD6uVwWWLfe9ESmf_WSNf4o3Z_0dKCRVL-mXkgnvSX_9K8doEirxPAGrgrsLUaXvQ",
         "user_type":"patient",
         "udid":"7b210431f6ce3b3e",
         "case_sensitive":"false"]*/
        
        
        if let uname:String = self.userPhoneNumber.text where
         uname.characters.count > kMinUserNameFieldCount {
            if let pass = self.userPassword.text where
            pass.characters.count > kMinPasswdFieldCount {
                let payload = ["username":uname as String,
                               "password":pass as String,
                               "type":"ios",
                               "token":"APA91bF0d4ffOB8q7xjDtFraC_5gv4w3EgvnwCdY34H7_yitLr",
                               "user_type":"patient",
                               "udid":"7b210431f6ce3b3e",
                               "case_sensitive":"false"]
                self.hideActivity(false)
                
                HumOSObjectModelFactory.sharedManager.getObjectOfType(.LoginObj, parameters: ["payload":payload]) { (obj) in
                    print(obj)
                    self.hideActivity(true)
                    let humOSObj = obj as! HumOSUserSession
                    if (humOSObj.success == true ) {
                        if (humOSObj.user?.accessToken) != nil {
                            PubNubHandler.sharedManager.setupConfig((HumOSObjectModelFactory.sharedManager.loginObject?.user?.userId)!)
                            dispatch_async(dispatch_get_main_queue(), {
                                self.dismissViewControllerAnimated(true, completion: nil)
                            })
                        } else {
                            if let msg = humOSObj.errorStr {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.displayAlert("Authorization Failure", message:msg)
                                })
                            } else {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.displayAlert("Authorization Failure", message:"Authorization Failure")
                                })
                            }
                        }
                    } else {
                        if let msg = humOSObj.errorStr {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.displayAlert("Error", message:msg)
                            })
                        }
                    }
                }
                
            } else {
                print("Credentials Cannot be Empty")
                //displayAlert("Enter Credentials", message: "Your Credentials are empty!!")
                self.userPassword.placeholder = "Required"
            }
        } else {
            print("Credentials Cannot be Empty")
            //displayAlert("Enter Credentials", message: "Your Credentials are empty")
            //self.userPhoneNumber.textColor = UIColor.redColor()
            self.userPhoneNumber.placeholder = "Required"
        }
    }
    
    @IBAction func forgotPassword(sender: AnyObject) {
        print("forgotPassword")
    }
    
    @IBAction func registerButton(sender: AnyObject) {
        print("registerButton")
    }
    
    // Mark: Manage content when keyboard pops up
    var activeField: UITextField?
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if activeField != nil {
            if (!CGRectContainsPoint(aRect, activeField!.frame.origin))
            {
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0,-keyboardSize!.height+keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
        textField.textColor = self.textOrginalColor
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }
    
    func displayAlert(title:String,message:String)  {
        let alert = UIAlertController(title: title , message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default) { (alert: UIAlertAction!) -> Void in
            NSLog("button OK")
        }
        
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion:nil)  // 11
    }
    
    func hideActivity(value:Bool) {
        if (value == true) {
            dispatch_async(dispatch_get_main_queue(), { 
                self.activityIndicator.stopAnimating()
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.startAnimating()
            })
        }
    }
    
    
}
