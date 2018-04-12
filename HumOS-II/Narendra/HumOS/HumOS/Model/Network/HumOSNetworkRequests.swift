//
//  HumOSNetworkRequests.swift
//  HumOS
//
//  Created by Nandu Ahmed on 8/30/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import Foundation

enum HumOSRequestType {
    case Login
    case ConnectedUsersDetails
    case DownloadMessage
    case CreatePatient
    case CreateSignUpVerificationCode
    case ValidateVerificationCode
    case RegisterUser
    case NewMessage

    func useAppVersion() -> String {
        switch self {
        case .Login:
            return "/v1"
            
        case .CreatePatient:
            return "/v1"
        
        case .CreateSignUpVerificationCode:
            return "/v1"
            
        case .ValidateVerificationCode:
            return "/v1"
            
        case .RegisterUser:
            return "/v1"
            
        case .ConnectedUsersDetails:
            return "/v1"
            
        default:
            return "/v2"
        }
    }
}


struct RequestConstants {
    
    static let providerURL = "https://sikkacfprovider.mybluemix.net"
    static let appEndPoint = "/api"
    static let version1 = "/v1"
    
    static let trueVaultBaseURL = "https://api.truevault.com"

}

class HumOSNetworkRequests {
    
    // GET Requests
    static func getRequestofType(requestType:HumOSRequestType, headers:NSDictionary?) -> NSURLRequest {
        var request:NSURLRequest!
        switch requestType {
            
        case .DownloadMessage:
            let endpoint = "/api/v2/messages/search"
            let url = RequestConstants.providerURL + endpoint
            request = createGETRequest(url, headers:headers)
            break
            
        case .CreatePatient:
            let endPoint = "/create_patient"
            let url = RequestConstants.providerURL + RequestConstants.appEndPoint + requestType.useAppVersion() + endPoint
            request = createGETRequest(url, headers: headers)
            break
            
            default:
                break
        }
        
        return request
    }
    
    // POST Requests
    static func postRequestofType(requestType:HumOSRequestType, headers:NSDictionary?, payload :NSDictionary? ) -> NSURLRequest {
        var request:NSURLRequest!
        switch requestType {
        case .Login:
            let endPoint = "/login"
            let url = RequestConstants.providerURL + RequestConstants.appEndPoint + requestType.useAppVersion() + endPoint
            request = createPOSTRequest(url, headers: headers, payload: payload, withAuthHeader: false)
            break
        
        case .CreateSignUpVerificationCode:
            let endPoint = "/create_verification_code"
            let url = RequestConstants.providerURL + RequestConstants.appEndPoint + requestType.useAppVersion() + endPoint
            request = createPOSTRequest(url, headers: headers, payload: payload, withAuthHeader: false)
            break
        
        case .ValidateVerificationCode:
            let endPoint = "/validate_verification_code"
            let url = RequestConstants.providerURL + RequestConstants.appEndPoint + requestType.useAppVersion() + endPoint
            request = createPOSTRequest(url, headers: headers, payload: payload, withAuthHeader: false)
            break
            
        case .RegisterUser:
            let endPoint = "/users"
            let url = RequestConstants.providerURL + RequestConstants.appEndPoint + requestType.useAppVersion() + endPoint
            request = createPOSTRequestWithFormData(url, headers: headers, payload: payload)
            break
            
        case .ConnectedUsersDetails:
            let endpoint = "/users/search"
            let url = RequestConstants.trueVaultBaseURL + requestType.useAppVersion() + endpoint
            request = createPOSTRequest(url, headers: headers, payload: nil, withAuthHeader: true)
        break
        case .NewMessage:
            let endpoint = "/messages"
            let url = RequestConstants.providerURL + RequestConstants.appEndPoint + requestType.useAppVersion() + endpoint
            request = createPOSTRequest(url, headers: headers, payload: payload, withAuthHeader: false)
            break
            
        default:
            break
        }
        return request
    }
    
    static func createGETRequest(SikkaURL:String , headers:NSDictionary?) -> NSURLRequest {
        var headerAsString:String = ""
        
        if (headers != nil && headers!.count > 0) {
            var separator = "?"
            for (key,value) in headers! {
                headerAsString += separator
                headerAsString += key as! String
                headerAsString += "="
                headerAsString += value as! String
                separator = "&"
            }
            
        }
        
        let fullUrlString = SikkaURL + headerAsString;
        let url = NSURL(string: fullUrlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 20
        request.HTTPShouldHandleCookies=false
        return request
    }
    
    static func createPOSTRequest(SikkaURL:String ,headers:NSDictionary?, payload:NSDictionary?, withAuthHeader:Bool) -> NSURLRequest {
        var headerAsString:String = ""
        
        if (headers != nil && headers!.count > 0) {
            var separator = "?"
            for (key,value) in headers! {
                headerAsString += separator
                headerAsString += key as! String
                headerAsString += "="
                headerAsString += value as! String
                separator = "&"
            }
        }
        
        print(headers)
        
        let fullUrlString = SikkaURL + headerAsString;
        let url = NSURL(string: fullUrlString)
        let request = NSMutableURLRequest(URL: url!)
        
        do {
            if (payload != nil) {
                let data = try NSJSONSerialization.dataWithJSONObject(payload!, options: [])
                let post = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
                request.HTTPBody = post.dataUsingEncoding(NSUTF8StringEncoding);
            }
        }catch {
            print("json error: \(error)")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if (withAuthHeader == true) {
            if let accessToken = HumOSObjectModelFactory.sharedManager.accessToken {
                let accessTokenEncoded = String(accessToken + ":").toBase64()
                let headerVal = "Basic "+accessTokenEncoded
                request.addValue(headerVal, forHTTPHeaderField: "Authorization")
            }
        }
        
        request.HTTPMethod = "POST"
        request.timeoutInterval = 80
        request.HTTPShouldHandleCookies=false
        return request
    }
    
    static func createPOSTRequestWithFormData(SikkaURL:String ,headers:NSDictionary?, payload:NSDictionary?) -> NSURLRequest {
        var headerAsString:String = ""
        
        if (headers != nil && headers!.count > 0) {
            var separator = "?"
            for (key,value) in headers! {
                headerAsString += separator
                headerAsString += key as! String
                headerAsString += "="
                headerAsString += value as! String
                separator = "&"
            }
        }
        
        print(headers)
        
        let fullUrlString = SikkaURL + headerAsString;
        let url = NSURL(string: fullUrlString)
        let request = NSMutableURLRequest(URL: url!)
        
        var payloadString = ""
        if (payload != nil && payload!.count > 0) {
            var separator = ""
            for (key,value) in payload! {
                payloadString += separator
                payloadString += key as! String
                payloadString += "="
                payloadString += value as! String
                separator = "&"
            }
        }
        
        request.HTTPBody = payloadString.dataUsingEncoding(NSUTF8StringEncoding);
        
        //        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        request.timeoutInterval = 80
        request.HTTPShouldHandleCookies=false
        return request
    }
    
    static private func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    
    static func createDELETERequest(SikkaURL:String , headers:NSDictionary?) -> NSURLRequest {
        var headerAsString:String = ""
        
        if (headers != nil && headers!.count > 0) {
            var separator = "?"
            for (key,value) in headers! {
                headerAsString += separator
                headerAsString += key as! String
                headerAsString += "="
                headerAsString += value as! String
                separator = "&"
            }
            
        }
        
        let fullUrlString = SikkaURL + headerAsString;
        let url = NSURL(string: fullUrlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "DELETE"
        request.timeoutInterval = 20
        request.HTTPShouldHandleCookies=false
        return request
    }
    
    static func createPUTRequest(SikkaURL:String ,headers:NSDictionary?, payload:NSDictionary?) -> NSURLRequest {
        var headerAsString:String = ""
        
        if (headers != nil && headers!.count > 0) {
            var separator = "?"
            for (key,value) in headers! {
                headerAsString += separator
                headerAsString += key as! String
                headerAsString += "="
                headerAsString += value as! String
                separator = "&"
            }
        }
        
        print(headers)
        
        let fullUrlString = SikkaURL + headerAsString;
        let url = NSURL(string: fullUrlString)
        let request = NSMutableURLRequest(URL: url!)
        
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(payload!, options: [])
            let post = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
            request.HTTPBody = post.dataUsingEncoding(NSUTF8StringEncoding);
        }catch {
            print("json error: \(error)")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "PUT"
        request.timeoutInterval = 80
        request.HTTPShouldHandleCookies=false
        return request
    }
}