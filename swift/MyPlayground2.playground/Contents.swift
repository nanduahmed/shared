//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


struct Person {
    var height:Float = 0
    var weight:Float = 0
    var name:String?
}


var person:Person? = Person()
var p2 = Person(height: 10, weight: 10, name: "P2")



print(person)

/*{
 "filter": {
 "$tv.id": {
 "type": "in",
 "value": [
 "e6d1b811-fef3-457b-a5e3-f1f1ea2ac091",
 "b21ed7b4-8a0c-4a40-b670-a8623b4b5abd"
 ]
 }
 },
 "filter_type": "and",
 "full_document": "true",
 " per_page": 500,
 "page": 1
 }*/

let d = ["filter":"", "filter_type":"and", "full_document":"true", "page":"1", "per_page":500]
do {
    
let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
}
catch let error as NSError {
    print(error)
}
