//
//  ViewController.swift
//  ScrollViewInsets
//
//  Created by Nandu Ahmed on 11/6/17.
//  Copyright © 2017 Nizaam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var sc2: UIScrollView!
    @IBOutlet weak var sc1: UIScrollView!
    var timer : Timer?
    var swit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(ViewController.fire), userInfo: nil, repeats: true)
        sc1.contentSize = CGSize(width: 1000, height: 2000)
//         sc1.contentSize = CGSize(width: 500, height: 500)
        self.sc1.backgroundColor = .blue
//        self.sc2.backgroundColor = .yellow
        self.sc1.contentInset = UIEdgeInsets(top: 20, left: 100, bottom: 200, right: 5)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 800, height: 2000))
        view.backgroundColor = .gray
        self.sc1.addSubview(view)
//
        let b = UIButton(type: .system)
        b.backgroundColor = .red
        b.setTitle("A Button", for: .normal)
        self.sc1.addSubview(b)
    }
    
    @objc func fire()  {
        if (self.swit == true) {
            self.sc1.backgroundColor = .red
//            self.sc2.backgroundColor = .green
        } else {
            self.sc1.backgroundColor = .green
//            self.sc2.backgroundColor = .red
        }
        self.swit = !swit
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
       
        
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

