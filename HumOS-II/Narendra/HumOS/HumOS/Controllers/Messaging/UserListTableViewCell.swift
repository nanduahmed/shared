//
//  UserListTableViewCell.swift
//  HumOS
//
//  Created by Deepesh.Sunku on 8/31/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import UIKit

class UserListTableViewCell: UITableViewCell {

    @IBOutlet weak var fromUserName: UILabel!
    @IBOutlet weak var initialsView: UIView!
    @IBOutlet weak var nameInitial: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.initialsView.layer.cornerRadius = initialsView.frame.width/2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
