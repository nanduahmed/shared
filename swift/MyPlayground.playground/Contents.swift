import  Foundation
//
//print("hello")
//
//let hour = 3
//let min = 30
//
//let d = Date()
//let flags = [Calendar.Component.day, Calendar.Component.month, Calendar.Component.year]
//var c = DateComponents()
////var c = DateComponents()
////var c = Calendar.current.component(flags, from: d)
////var c = Calendar.current.component(Calendar.Component.day, from: d)
//c.calendar = Calendar.current
//c.hour = hour
//c.minute = min
//
//
//let exactDate = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)?.date(from: c)
//
//
//let date = NSDate()
//let unitFlags = Set<Calendar.Component>([.hour, .day, .month, .year])
//var co = NSCalendar.current.dateComponents(unitFlags, from: date as Date)
//co.calendar = Calendar.current
//co.hour = hour
//co.minute = min
//co.date
//
//let d1 = NSDate.init(timeInterval: 1000, since: date as Date)
//let d2 = NSDate.init(timeInterval: 2000, since: date as Date)
//let d3 = NSDate.init(timeInterval: 3000, since: date as Date)
//let d4 = NSDate.init(timeInterval: 4000, since: date as Date)
//let d5 = NSDate.init(timeInterval: 5000, since: date as Date)
//let d6 = NSDate.init(timeInterval: 6000, since: date as Date)
//let d7 = NSDate.init(timeInterval: 7000, since: date as Date)
//let d8 = NSDate.init(timeInterval: 8000, since: date as Date)
//
//
//let dates = [date , d1,d2,d3,d4,d5,d6,d7,d8]
//
//let tafTroneHour = date.addingTimeInterval(3600).timeIntervalSince1970
//print(tafTroneHour)
//
//for d in dates where d.timeIntervalSince1970 < tafTroneHour {
//    print(d.timeIntervalSince1970)
//    print(d)
//}
//
//// "Jul 23, 2014, 11:01 AM" <-- looks local without seconds. But:
//let dd = Date()
//var formatter = DateFormatter()
//formatter.dateFormat = "yyyy-MM-dd HH:mm"
//formatter.dateFormat = "MMM d, yyyy "
//formatter.dateStyle = .medium
//var defaultTimeZoneStr = formatter.string(from: dd)
//formatter.dateFormat = "E h:mm a"
//formatter.dateStyle = .medium
//defaultTimeZoneStr = formatter.string(from: dd)
//// "2014-07-23 11:01:35 -0700" <-- same date, local, but with seconds
//formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!
//let utcTimeZoneStr = formatter.string(from: dd)
//
//
//let t = date.timeIntervalSince1970
//let da = round(t)
//
//
//var dateFormatter = DateFormatter()
//let ts = 1478829600
//let apptLength = 3600
//let timeStartDate = Date.init(timeIntervalSince1970: TimeInterval(ts))
////df.dateStyle = .medium
//dateFormatter.dateFormat = "EE. hh:mm a"
//var st = dateFormatter.string(from: timeStartDate)
//
//let timeEndDate = timeStartDate.addingTimeInterval(TimeInterval(apptLength))
//dateFormatter.dateFormat = " - hh:mm a"
//var st2 = dateFormatter.string(from: timeEndDate)
//
//var a = st + st2

// Arrival Time
var components = DateComponents.init()
components.year = 2016
components.month = 11
components.day = 14
components.hour = 18
components.minute = 10
components.second = 0

let apptDate = Calendar.current.date(from: components)

let now = Date()
let arriving = Date(timeInterval: 30*60, since: now)

let tIApptDate = apptDate?.timeIntervalSince1970
let nowTI:TimeInterval? = now.timeIntervalSince1970
let arrivingTI:TimeInterval? = arriving.timeIntervalSince1970

var aVar:String?

if (Double(tIApptDate!) > Double(arrivingTI!)) {
    if ((tIApptDate! - arrivingTI!) < 179) {
        print("Waiting")
        aVar = "W"
    } else {
        print("Arrived")
        aVar = "A"
    }
} else {
    if ((arrivingTI! - tIApptDate!) > 179) {
        print("Late by \((arrivingTI! - tIApptDate!)/60) mins this")
        aVar = "L"
    } else {
        print("On Time")
        aVar = "O"
    }
}

let ac = Date(timeInterval: -8*60*60, since: now)

let df = DateFormatter()
df.dateFormat = "MMM-dd h:mm a"

var a = df.string(from: ac)

var times = [now, arriving , ac]

class ab {
    var n:String?
    var t:Date?
}
var a1 = ab()
a1.n = "1"
a1.t = now

var a2 = ab()
a2.n = "2"
a2.t = arriving

var a3 = ab()
a3.n = "3"
a3.t = ac

let ad = Date(timeInterval: 2*60*60*60, since: now)

var a4 = ab()
a4.n = "--4"
a4.t = ad


var obj = [a1,a2,a3,a4]

times.sort() {
    $0 > $1
}

obj.sort { (a, b) -> Bool in
    a.t! < b.t!
}

for (index, a) in obj.enumerated()  where a.t! < Date(){
    var val = df.string(from: a.t!)
    let st = a.n! + " is " + val + " idx " + String(index)
    print(st)
    
}














