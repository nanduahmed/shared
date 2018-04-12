//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

var str = "Hello, playground"

func filterSageCardsFromData(data:NSArray) -> [String] {
    let array:NSMutableArray = NSMutableArray.init()
    let items = data[0]["items"] as! NSArray
    print(items.count)
    for item in items {
        if (item["parent"] as! String == "Sage") {
            print(item["child_name"])
            array.addObject(item["child_name"])
            
        }
    }
    print("returninh")
        return array
}


let url = NSURL(string: "https://api.sikkasoft.com/v2/practice_mobilizer_menus?request_key=0e4f6a30f5829be8cd16351e6f6d9da7")
let request = NSURLRequest(URL: url!)

NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.currentQueue()!) { response, maybeData, error in
    if let data = maybeData {
        let contents = NSString(data:data, encoding:NSUTF8StringEncoding)
        print("Nandu")
        do {
            print("Ahmed")
            let s = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            print(s)
            if let jsonResult = s as? NSMutableArray
            {
                print(jsonResult)
                print(jsonResult[0])
                let a = filterSageCardsFromData(jsonResult)
                print(a)
//                return jsonResult //Will return the json array output
            }
            
        } catch let error as NSError {
            print("error "+error.localizedDescription)
        }
    } else {
        print(error!.localizedDescription)
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
