//
//  CodeValidationViewController.swift
//  HumOS
//
//  Created by Deepesh.Sunku on 9/1/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import UIKit

class CodeValidationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var verificationTextField: UITextField!
    var user : NewUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.hidden = false
        verificationTextField.delegate = self
        
        verificationTextField.layer.borderWidth = 1.0
        verificationTextField.layer.cornerRadius = 5
        verificationTextField.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func resendCodeAction(sender: AnyObject) {
        createVerificationCode(user)
    }
    
    func createVerificationCode(user: NewUser?){
        self.hideActivity(false)
        guard let email = user?.email, vaultId = user?.vaultId, let documentId = user?.documentId, let phone = user?.phone else{
            return
        }
        let payload : [String:AnyObject] = ["email":email, "vault_id":vaultId, "document_id":documentId, "phone_number":phone]
        HumOSObjectModelFactory.sharedManager.getObjectOfType(.CreateSignVerificationCode, parameters:["payload":payload]) { (obj) in
            print(obj)
            if(obj.success == true && user != nil) {
                self.hideActivity(true)
                self.displayAlert("Success", message: "A new verification code was sent to you.")
            } else {
                self.hideActivity(true)
                self.displayAlert("Cannot Complete Request", message: obj.errorStr!)
            }
        }
    }
    
    @IBAction func validateButtonAction(sender: AnyObject) {
        self.hideActivity(false)
        if verificationTextField.text == "" {
            self.hideActivity(true)
            self.displayAlert("Required Field", message: "Please enter the validation code you received.")
        } else {
            let payload : [String:AnyObject] = ["verification_code": verificationTextField.text!, "vault_id":user!.vaultId!, "document_id":user!.documentId!]
            HumOSObjectModelFactory.sharedManager.getObjectOfType(.ValidateVerificationCode, parameters:["payload":payload]) { (obj) in
                print(obj)
                if(obj.success == true) {
                    self.hideActivity(true)
                    self.goToCompleteRegistration(self.user!)
                } else {
                    self.hideActivity(true)
                    self.displayAlert("Cannot Complete Request", message: obj.errorStr!)
                }
            }
        }
    }
    
    func goToCompleteRegistration(user : NewUser){
        dispatch_async(dispatch_get_main_queue(), {
            let storyboard = UIStoryboard(name: "RegistrationStoryboard", bundle: nil)
            if let vc = storyboard.instantiateViewControllerWithIdentifier("RegisterUserViewController") as? RegisterUserViewController {
                vc.user = user
                self.navigationController?.pushViewController(vc, animated: true)
//                self.presentViewController(vc, animated: true, completion: nil)
            }
        })
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
