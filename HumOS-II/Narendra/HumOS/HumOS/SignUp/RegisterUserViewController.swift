//
//  RegisterUserViewController.swift
//  HumOS
//
//  Created by Deepesh.Sunku on 9/1/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import UIKit

class RegisterUserViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var user:NewUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.hidden = false
        
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
        
        confirmPasswordTextField.layer.borderWidth = 1.0
        confirmPasswordTextField.layer.cornerRadius = 5
        confirmPasswordTextField.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerButtonAction(sender: AnyObject) {
        self.hideActivity(false)
        if passwordTextField.text == "" {
            self.hideActivity(true)
            self.displayAlert("Required Field", message: "Please enter a password.")
        } else if confirmPasswordTextField.text == "" {
            self.hideActivity(true)
            self.displayAlert("Required Field", message: "Please enter a confirmation password.")
        } else if confirmPasswordTextField.text != passwordTextField.text {
            self.hideActivity(true)
            self.displayAlert("Password Error", message: "Please make sure your passwords match.")
        } else {
            
            let payload : [String:AnyObject] = [
                "email" : user!.email!,
                "username" : user!.phone!,
                "first_name" : user!.firstName!,
                "last_name" : user!.lastName!,
                "password" : passwordTextField.text!,
                "phone" : user!.phone!,
                "type" : "patient"]
            
            HumOSObjectModelFactory.sharedManager.getObjectOfType(.RegisterUser, parameters:["payload":payload]) { (obj) in
                print(obj)
                self.user?.password = self.passwordTextField.text!
                if(obj.success == true) {
                    self.hideActivity(true)
                    self.displayAlert("Registration complete!", message: "Please login in with your credentials now.")
                    dispatch_async(dispatch_get_main_queue(), {
                        let storyboard = UIStoryboard(name: "RegistrationStoryboard", bundle: nil)
                        if let vc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController {
                            self.navigationController?.pushViewController(vc, animated: true)
//                            self.presentViewController(vc, animated: true, completion: {
//                                self.displayAlert("Registration complete!", message: "Please login in with your credentials now.")
//                            })
                        }
                    })
                } else {
                    self.hideActivity(true)
                    self.displayAlert("Cannot Complete Request", message: obj.errorStr!)
                }
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
