//
//  NetworkHandler.swift
//  BGTask
//
//  Created by Nandu Ahmed on 8/3/17.
//  Copyright © 2017 Nizaam. All rights reserved.
//

import UIKit

class NetworkHandler {
    
    func getCallToServer(params:[String:String], completion:@escaping (_ data:String) -> (Void)) {
        print("Caal")
        
        let todoEndpoint: String = "http://192.168.2.122:3000/todos"
        guard let url = URL(string: todoEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler:{ data, resp, error in
            print(resp?.url?.absoluteString ?? "sdf")
            completion("Great")
        })

        task.resume()
    }

}
