//
//  SettingsViewController.swift
//  HumOS
//
//  Created by Jane.Yuan on 9/1/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UIView!
    @IBOutlet weak var phone: UIView!
    @IBOutlet weak var password: UIView!
    @IBOutlet weak var gender: UIView!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.barTintColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0)
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.barStyle = UIBarStyle.Black
        navigationController?.navigationBar.hidden = false
        
        saveButton.layer.borderWidth = 1.0
        saveButton.layer.cornerRadius = 8
        saveButton.layer.borderColor = UIColor(red:1.0, green:1.0, blue:1.00, alpha:1.0).CGColor
        
        deleteButton.layer.borderWidth = 1.0
        deleteButton.layer.cornerRadius = 8
        deleteButton.layer.borderColor = UIColor(red:1.0, green:1.0, blue:1.00, alpha:1.0).CGColor
        
        displayName.layer.borderWidth = 1.0
        displayName.layer.cornerRadius = 5
        displayName.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
        
        name.layer.borderWidth = 1.0
        name.layer.cornerRadius = 5
        name.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
        
        password.layer.borderWidth = 1.0
        password.layer.cornerRadius = 5
        password.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
        
        gender.layer.borderWidth = 1.0
        gender.layer.cornerRadius = 5
        gender.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
        
        phone.layer.borderWidth = 1.0
        phone.layer.cornerRadius = 5
        phone.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
        
        email.layer.borderWidth = 1.0
        email.layer.cornerRadius = 5
        email.layer.borderColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0).CGColor
    }

    
    @IBAction func saveChangeAction(sender: AnyObject) {
        print("save")
    }

    @IBAction func deleteAccountAction(sender: AnyObject) {
        print("delete")
    }

}
