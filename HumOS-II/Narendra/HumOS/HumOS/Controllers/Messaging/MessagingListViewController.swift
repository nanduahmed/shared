//
//  ChatList.swift
//  HumOS
//
//  Created by Nandu Ahmed on 8/31/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import UIKit

class MessagingListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var connectedUsers:ConnectedUsersModel?
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var noMessageView: UIView!
    var count: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.noMessageView.hidden = true
        
        // Do any additional setup after loading the view, typically from a nib.
        navigationController!.navigationBar.barTintColor = UIColor(red:0.14, green:0.74, blue:1.00, alpha:1.0)
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.barStyle = UIBarStyle.Black
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let loginObj = HumOSObjectModelFactory.sharedManager.loginObject where
            loginObj.success == true {
            print("login Details \(loginObj)")
            
            HumOSObjectModelFactory.sharedManager.getObjectOfType(.ConnectedUsersObj, parameters:["":""], completion: { (obj) in
                
                self.connectedUsers = obj as? ConnectedUsersModel
                print (self.connectedUsers?.connectedUsersList)
                if(self.connectedUsers?.connectedUsersList?.count <= 0){
                    self.noMessageView.hidden = false
                    self.tableView.hidden = true
                } else {
                    self.noMessageView.hidden = true
                    self.tableView.hidden = false
                }
                dispatch_async(dispatch_get_main_queue(), { 
                    self.tableView.reloadData()
                })
            })
            
        } else {
            self.performSegueWithIdentifier("loginSegue", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.connectedUsers?.connectedUsersList?.count {
            return count
        } else {
            return 0
        }
    }
  
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        func initialsCreator(first: String) -> String {
            return "\(first[first.startIndex.advancedBy(0)])"
        }
        
        func randomCol() -> UIColor {
            // If you wanted a random alpha, just create another
            // random number for that too.
            let colorArray = ["#F10034", "#F6831E", "#53B3FC", "#3ED33E", "#418FE5", "#F6831E", "#F10034", "#F6831E", "#53B3FC", "#3ED33E", "#418FE5", "#F6831E"]
            if(count == nil || count > 4) {
                count = 0
            } else {
                count = count!+1
            }
            
            return UIColor(rgba: colorArray[count!])
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("userListCell") as! UserListTableViewCell
        let user:ConnectedUsersInfo = (self.connectedUsers?.connectedUsersList![indexPath.row])!
        cell.fromUserName.text = user.firstName + " " + user.lastName
        cell.nameInitial.text = initialsCreator(user.firstName)
        cell.initialsView.backgroundColor = randomCol()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc : MessageDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MessageDetailViewController") as! MessageDetailViewController
        let user:ConnectedUsersInfo = (self.connectedUsers?.connectedUsersList![indexPath.row])!
        vc.otherUserId = user.userId
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
