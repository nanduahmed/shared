//
//  ViewController.swift
//  SelfSizingTableViewCells
//
//  Created by Nandu Ahmed on 11/17/17.
//  Copyright © 2017 Nizaam. All rights reserved.
//

import UIKit

struct Vals {
    var name:String?
    var desc:String?
    var hide = false
}

class ViewController: UIViewController, UITableViewDataSource, OnPress , UITableViewDelegate{
    @IBOutlet weak var tableView: UITableView!
    var hide = true
    
    var items = ["A", "B", "C", "D"]
    var details = ["reloadRowsAtIndexPaths",
                   "The Boolean flag which hides/shows the description label is inversed on a cell tap, followed by the table reloading the concerned row. The stackview automatically adjusts its height based on the visibility of its subviews. Speaking of heights... Make sure you add these two bad boys inside",
                   "The Boolean flag which hides/shows the description label is inversed on a cell tap, followed by the table  Speaking of heights... Make sure you add these two bad boys inside",
                   "The Boole Speaking of heights... Make sure you add these two bad boys inside"]
    
    var values:[Vals]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.estimatedRowHeight = 300
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.values = [Vals.init(name: items[0], desc: details[0], hide: false),
                       Vals.init(name: items[1], desc: details[1], hide: false),
                       Vals.init(name: items[2], desc: details[2], hide: false),
                       Vals.init(name: items[3], desc: details[3], hide: false)]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (1 == 0 ) {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "asecondcell") as! ASecondTableViewCell
//            cell.nameLabel.text = values![indexPath.row].name
//            cell.detailLabel.text = values![indexPath.row].desc
//            cell.detailLabel.isHidden = values![indexPath.row].hide
            //        cell.delegate = self
            cell.update(valA: values![indexPath.row].name!, B: values![indexPath.row].desc!)
            //        cell.index = indexPath.row
            return cell
        }
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "sizingCellId") as! SizingTableViewCell
        cell.nameLabel.text = values![indexPath.row].name
        cell.detailLabel.text = values![indexPath.row].desc
        cell.detailLabel.isHidden = values![indexPath.row].hide
//        cell.delegate = self
//        cell.index = indexPath.row
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func onPress(index: Int) {
        //self.tableView.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SizingTableViewCell
        values![indexPath.row].hide = !values![indexPath.row].hide
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

