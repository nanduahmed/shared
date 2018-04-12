//
//  ASecondTableViewCell.swift
//  SelfSizingTableViewCells
//
//  Created by Nandu Ahmed on 1/17/18.
//  Copyright © 2018 Nizaam. All rights reserved.
//

import UIKit

class ASecondTableViewCell: UITableViewCell {

    @IBOutlet weak var aLabel: UILabel!
    @IBOutlet weak var bLabel: UILabel!
    @IBOutlet weak var cLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
     func update(valA:String, B:String)  {
        self.aLabel.text = valA
        self.bLabel.text = B
        self.cLabel.text = "wefwefwefwefwefwefwefw"
        
    }

}
