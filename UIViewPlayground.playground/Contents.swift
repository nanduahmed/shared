//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

var str = "Hello, playground"

var button = UIButton(type: UIButtonType.system)
button.backgroundColor = UIColor.blue
button.setTitle("AAA", for: .normal)
let img = UIImage.init(named: "A")
//button.setImage(img, for: .normal)
button.frame = CGRect(x: 50, y: 6, width: 44, height: 30)


let badge = UILabel(frame: CGRect(x: 38, y: -5 , width: 25, height: 25 ))
badge.text = "1"
badge.backgroundColor = UIColor.white
button.addSubview(badge)



let f = CGRect(x: 1, y: 1, width: 100, height: 100)
let aview = UIView(frame: f)
//aview.frame = CGRect(x: 1, y: 1, width: 100, height: 100)
aview.backgroundColor = UIColor.green
PlaygroundPage.current.liveView = aview

aview.addSubview(button)


UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionFlipFromTop], animations: {
    let frame = CGRect(x: 50, y: 16, width: 44, height: 30)
    button.frame = frame
}) { (val) in
    print("c \(val)")
}

