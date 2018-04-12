//
//  NetworkInterface.swift
//  HumOS
//
//  Created by Nandu Ahmed on 8/30/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import Foundation



typealias HumOSRequestCompletionType = (Bool, NSDictionary?, NSURLResponse?, ErrorType?) -> (Void)

class NetworkInterface: NSObject {
    
    static func fetchJSON(requestType:HumOSRequestType , headers:NSDictionary? , requestCompletionHander:HumOSRequestCompletionType)  {
        
        self.sendAsyncRequest(HumOSNetworkRequests.getRequestofType(requestType, headers: headers)) { (success, json, response, error) -> (Void) in
            if (success == true && response != nil) {
                
                let httpResponse:NSHTTPURLResponse = response as! NSHTTPURLResponse
                let httpStatusCode = httpResponse.statusCode
                
                switch httpStatusCode {
                    
                case 200:
                    let succcess = (json != nil)
                    if (succcess) {
                        requestCompletionHander(succcess, json, response, nil)
                    } else {
                        requestCompletionHander(false, nil, response , DataErrors.InvalidJSONData)
                    }
                    break
                    
                case 204:
                    requestCompletionHander(false, nil, response, HumOSNetworkError.HTTPStatus204)
                    break
                case 404:
                    requestCompletionHander(false,nil,response,HumOSNetworkError.HTTPStatus404)
                    break
                case 410:
                    requestCompletionHander(false, nil, response, HumOSNetworkError.HTTPStatus410)
                    break
                default:
                    requestCompletionHander(false,nil,response,HumOSNetworkError.HTTPStatusUnknownError)
                    break
                }
            }
            else {
                requestCompletionHander(false,nil,response,error)
            }
            
        }
    }
    
    static func fetchJSON(requestType:HumOSRequestType , headers:NSDictionary?, payload :NSDictionary?  , requestCompletionHander:HumOSRequestCompletionType) {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            //TODO: Implement the cases for HTTP Code as for GET and TEST
            self.sendAsyncRequest(HumOSNetworkRequests.postRequestofType(requestType, headers:headers, payload: payload ), completionHandler: { (suc, json, response, error) -> (Void) in
                let succcess = (json != nil)
                requestCompletionHander(succcess,json, response,error)
                
            })
        }
    }
    
    
    static private func sendAsyncRequest(request:NSURLRequest, completionHandler:HumOSRequestCompletionType) {
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response, data, error) in
            do {
                if (response != nil && data != nil) {
                    if let json = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as? AnyObject {
                        print("Response from DISPATCH ASYNC URL \(response?.URL) \(json)")
                        if (json.isKindOfClass(NSArray)) {
                            let arrayOfJson = ["array":json]
                            completionHandler(true,arrayOfJson, (response as! NSHTTPURLResponse), nil)
                        } else {
                            completionHandler(true,json as? NSDictionary ,(response  as! NSHTTPURLResponse), nil)
                        }
                    } else {
                        completionHandler(false, nil, (response as! NSHTTPURLResponse), DataErrors.InvalidJSONData)
                    }
                } else {
                    completionHandler(false, nil, response , DataErrors.NoData)
                }
            }catch let error as NSError {
                print(error.localizedDescription)
                completionHandler(false, nil,response,DataErrors.DataParseError)
            }
            
        }
    }
}
