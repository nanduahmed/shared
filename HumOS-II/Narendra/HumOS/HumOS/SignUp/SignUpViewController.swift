//
//  SignUpViewController.swift
//  HumOS
//
//  Created by Deepesh.Sunku on 8/30/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var outerCircle: UIView!
    @IBOutlet weak var middleCircle: UIView!
    @IBOutlet weak var innerCircle: UIView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var countryCode: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var email: UITextField!
    var tosChecked = false
    let checkboxSelected = UIImage(named: "checkBoxSelected")
    let checkboxUnselected = UIImage(named: "checkBoxUnSelected")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.barTintColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0)
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.barStyle = UIBarStyle.Black
        navigationController?.navigationBar.hidden = true
        
        displayName.delegate = self
        firstName.delegate = self
        lastName.delegate = self
        phone.delegate = self
        email.delegate = self
        countryCode.delegate = self
        
        self.registerForKeyboardNotifications()
        self.scrollView.keyboardDismissMode = .Interactive
        
        // Mark: Section for adding Borders for views and rounding views
        displayName.layer.borderWidth = 1.0
        displayName.layer.cornerRadius = 5
        displayName.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
        
        firstName.layer.borderWidth = 1.0
        firstName.layer.cornerRadius = 5
        firstName.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
        
        lastName.layer.borderWidth = 1.0
        lastName.layer.cornerRadius = 5
        lastName.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
        
        countryCode.layer.borderWidth = 1.0
        countryCode.layer.cornerRadius = 5
        countryCode.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
        
        phone.layer.borderWidth = 1.0
        phone.layer.cornerRadius = 5
        phone.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
        
        email.layer.borderWidth = 1.0
        email.layer.cornerRadius = 5
        email.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // Mark: Manage content when keyboard pops up
    @IBAction func continueButtonAction(sender: AnyObject) {
        
        if displayName.text == "" {
            displayAlert("Required Field", message: "Please enter a Display Name.")
        } else if firstName.text == "" {
            displayAlert("Required Field", message: "Please enter a First Name.")
        } else if lastName.text == "" {
            displayAlert("Required Field", message: "Please enter a Last Name.")
        } else if countryCode.text == "" {
            displayAlert("Required Field", message: "Please enter a Country Code.")
        } else if phone.text == "" {
            displayAlert("Required Field", message: "Please enter a Phone Number.")
        } else if email.text == "" {
            displayAlert("Required Field", message: "Please enter a Email.")
        } else if tosChecked == false {
            displayAlert("Terms", message: "Please accept the Terms of Service.")
        } else {
            self.hideActivity(false)
            
            let parameters = ["first_name":firstName.text! as String,
                           "last_name":lastName.text! as String,
                           "email":email.text! as String,
                           "phone":phone.text! as String,
                           "status":"unverified",
                           "verification_code":"",
                           "is_user": "0"]
            
            HumOSObjectModelFactory.sharedManager.getObjectOfType(.CreatePatientObj, parameters:["urlParams":parameters]) { (obj) in
                print(obj)
                if(obj.success == true) {
                    let newUser = obj as? NewUser
                    newUser?.displayName = self.displayName.text
                    newUser?.firstName = self.firstName.text
                    newUser?.lastName = self.lastName.text
                    self.createVerificationCode(newUser)
                } else {
                    self.hideActivity(true)
                    self.displayAlert("Cannot Complete Request", message: obj.errorStr!)
                }
            }
        }
    }
    
    func createVerificationCode(user: NewUser?){
        guard let email = user?.email, vaultId = user?.vaultId, let documentId = user?.documentId, let phone = user?.phone else{
            return
        }
        let payload : [String:AnyObject] = ["email":email, "vault_id":vaultId, "document_id":documentId, "phone_number":phone]
        HumOSObjectModelFactory.sharedManager.getObjectOfType(.CreateSignVerificationCode, parameters:["payload":payload]) { (obj) in
            print(obj)
            if(obj.success == true && user != nil) {
                self.hideActivity(true)
                self.gotoVerification(user!)
            } else {
                self.hideActivity(true)
                self.displayAlert("Cannot Complete Request", message: obj.errorStr!)
            }
        }
    }
    
    func gotoVerification(user : NewUser){
        dispatch_async(dispatch_get_main_queue(), {
            let storyboard = UIStoryboard(name: "RegistrationStoryboard", bundle: nil)
            if let vc = storyboard.instantiateViewControllerWithIdentifier("CodeValidationViewController") as? CodeValidationViewController {
                vc.user = user
                self.navigationController?.pushViewController(vc, animated: true)
//                self.presentViewController(vc, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func gotToLoginAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func termsCheckBox(sender: AnyObject) {
        if(tosChecked) {
            tosChecked = false
            sender.setImage(checkboxUnselected, forState: UIControlState.Normal)
        } else {
            tosChecked = true
            sender.setImage(checkboxSelected, forState: UIControlState.Normal)
        }
    }
    
    @IBAction func termPageAction(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.sikkasoft.com/privacy-policy/")!)
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
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alert, animated: true, completion:nil)
        })
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
