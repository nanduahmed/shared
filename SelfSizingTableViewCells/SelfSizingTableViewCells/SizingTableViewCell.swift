//
//  SizingTableViewCell.swift
//  SelfSizingTableViewCells
//
//  Created by Nandu Ahmed on 11/17/17.
//  Copyright © 2017 Nizaam. All rights reserved.
//

import UIKit

protocol OnPress {
    func onPress(index:Int)
}

class SizingTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    
    
    var clicked = false
    var hide = false
    var delegate:OnPress?
    var index:Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onClick(_ sender: UIButton) {
//        self.clicked = !clicked
//        self.detailLabel.isHidden = self.clicked
//        self.delegate?.onPress(index: self.index)
    }
}
