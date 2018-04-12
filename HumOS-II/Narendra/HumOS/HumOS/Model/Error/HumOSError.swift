//
//  HumOSError.swift
//  HumOS
//
//  Created by Nandu Ahmed on 8/30/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import Foundation


enum HumOSNetworkError : ErrorType {
    case HTTPStatus201
    case HTTPStatus204
    case HTTPStatus400
    case HTTPStatus404
    case HTTPStatus410
    case HTTPStatusUnknownError
}

enum DataErrors : ErrorType {
    case InvalidJSONData
    case DataParseError
    case NoData
}