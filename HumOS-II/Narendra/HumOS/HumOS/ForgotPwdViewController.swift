//
//  ForgotPwdViewController.swift
//  HumOS
//
//  Created by Jane.Yuan on 8/30/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import UIKit


class ForgotPwdViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userPhoneNumber: UITextField!
    
    @IBOutlet weak var getPwdButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userPhoneNumber.layer.borderWidth = 1.0
        userPhoneNumber.layer.cornerRadius = 5
        userPhoneNumber.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
        
        getPwdButton.layer.borderWidth = 1.0
        getPwdButton.layer.cornerRadius = 5
        getPwdButton.layer.borderColor = UIColor(red:0.06, green:0.47, blue:1.00, alpha:1.0).CGColor
        
    }
    
    
    
    @IBAction func loginSelected(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func registerSelected(sender: AnyObject) {
        print("registerButton")
    }
    
    @IBAction func getPasswordSelected(sender: AnyObject) {
        
    }
    
    
    
}
