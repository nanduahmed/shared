//
//  ViewController.swift
//  HumOS
//
//  Created by Deepesh.Sunku on 8/29/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        navigationController!.navigationBar.barTintColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0)
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.barStyle = UIBarStyle.Black
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let loginObj = HumOSObjectModelFactory.sharedManager.loginObject where
         loginObj.success == true {
            print("login Details \(loginObj)")
            
            HumOSObjectModelFactory.sharedManager.getObjectOfType(.ConnectedUsersObj, parameters:["":""], completion: { (obj) in
                
            let connectedUsers = obj as? ConnectedUsersModel
                print (connectedUsers?.connectedUsersList)
            })
            
            
        } else {
            self.performSegueWithIdentifier("loginSegue", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("messageCardReuseIdentifier", forIndexPath: indexPath)
        cell.layer.cornerRadius = 10;
        cell.layer.borderWidth = 1;
        cell.layer.borderColor = UIColor.clearColor().CGColor;
        cell.layer.masksToBounds = true;
        
        cell.layer.shadowColor = UIColor.lightGrayColor().CGColor;
        cell.layer.shadowOffset = CGSize(width: 1, height: 2);
        cell.layer.shadowRadius = 3.0;
        cell.layer.shadowOpacity = 0.5;
        return cell
    }
    
}

