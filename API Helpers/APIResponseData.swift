//
//  APIResponseData.swift
//  ACMA Event
//
//  Created by Hardik Shah on 25/02/18.
//  Copyright © 2018 ThetaTechnolabs. All rights reserved.
//

import Foundation

open class APIResponseData {
    
    
    var success:Bool = false
    var response:[String:Any]?
    var error:NSError?
    var operation:APINetworkOperation?
    var data:AnyObject?
    var timestamp:NSNumber?
    var shouldUpdate:Bool = false 
    init(response:[String:Any]?,error:NSError?,operation:APINetworkOperation?) {
        self.response = response
        self.error = error
        self.operation = operation
    }
    
    static func getEmptyResponseData() -> APIResponseData{
    
        return APIResponseData(response: nil, error: nil, operation: nil)
    
    }
    
}
