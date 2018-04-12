//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

//let vals = [10,11,12,13,13,14,15, 9]
//
//let squares = vals.map {$0+$0}
//let words = vals.map {NumberFormatter.localizedString(from: NSNumber.init(value: $0), number: .spellOut)}
//print(words)
enum someVals {
    case one
    case two
    case three
}


class aClass : NSObject, NSCoding {
    var anInt:Int?
    var patId:Int?
    var garId:Int?
    var aString:String?
    var another:String?
    var enumVals:someVals?
    
    func printIt()  {
        print("anInt \(self.anInt) aString \(self.aString) and another \(self.another) patId \(self.patId) garId \(self.garId)  and enum \(self.enumVals)")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(aString, forKey:"firstName")
        aCoder.encode(anInt, forKey:"lastName")
        aCoder.encode(self.enumVals?.hashValue, forKey: "env")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    override init() {
        self.another = "Init"
        self.enumVals = someVals.two
    }
    
}

var item = aClass.init()
item.anInt = 10
item.aString = "ABC"
item.another = "Nandu"
item.patId = 10
item.garId = 100
//item.printIt()

var item2 = aClass.init()
item2.anInt = 20
item2.aString = "DEF"
item2.another = "Nandu2"
//item2.printIt()
item2.patId = 10
item2.garId = 101

var item3 = aClass.init()
item3.anInt = 31
item3.aString = "GHI"
item3.another = "Nandu3"
//item3.printIt()
item3.patId = 11
item3.garId = 102

var item4 = aClass.init()
item4.anInt = 40
item4.aString = "JKL"
item4.another = "Nandu4"
//item4.printIt()
item4.patId = 12
item4.garId = 102

//let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.allDomainsMask, true)
//let path: AnyObject = paths[0] as AnyObject
//let arrPath = path.appending("/arrayA.plist")
//
//let a = NSKeyedArchiver.archiveRootObject([1,2, "ABC", "DEF", item, item2], toFile: arrPath)
//
//let file = NSKeyedUnarchiver.unarchiveObject(withFile: arrPath)
//if let tempArr = NSKeyedUnarchiver.unarchiveObject(withFile: arrPath) as? [Any] {
//    print(tempArr)
//    for a in tempArr  {
//        if a is aClass {
//            print(a)
//            if let v = a as? aClass {
//                print(v.aString)
//                v.printIt()
//                print(v.enumVals)
//            }
//        }
//    }
//    print("Coll")
//
//}

let timeIntervalNow = Date()
let timeIntervalObjCreated = Date.init(timeInterval: -8*3600, since: Date())

let eightHourTimeInterval = 8*60.0*60.0 as! TimeInterval
let dailyLimit = timeIntervalObjCreated + eightHourTimeInterval

if (timeIntervalNow.timeIntervalSince1970 - (timeIntervalObjCreated.timeIntervalSince1970 + eightHourTimeInterval) > 0) {
    print("ABC")
} else {
    print("DEF")
}


//var items = [item, item2, item3, item4]
//var filter = items.filter { $0.anInt == 10 || $0.another == "Nandu3" }
//var anotherFilter = items.filter {
//    let a = $0
//    
//    for b in items where a.patId == b.patId && a.anInt != b.anInt {
//        b.printIt()
//        return true
//    }
//    
//    return false
//}


func initA(dict:[String:Any]?) -> [String:Any]? {
    guard dict != nil else {
        let success = false
        print("nil")
        return nil
    }

    print(dict ?? "AAAA")
    return dict
}

print("V \(initA(dict: nil))" )
if let a = initA(dict: ["A":"B"]) {
    print("V \(a)" )
}




