//
//  APIResponseHandler.swift
//  ProfessionalDating
//
//

import UIKit
import Foundation
@objc

open class APIResponseHandler: NSObject {

    var success: Bool = false
    var message: String?
    var message_description: String?
    var data: AnyObject?
    var error:[String:Any]?
    var main_response:[String:Any?]?
    public var timestamp:NSNumber?

    public init(dictionary: [String:Any?]) {
        super.init()
        
        
        self.timestamp = dictionary["timestamp"] as? NSNumber
        let isError = dictionary["error"] as?  Bool ?? (dictionary["error"] as? String != nil) 
        self.main_response = dictionary
        self.error = dictionary["error"] as? [String:Any]
        self.data = dictionary["response"] as AnyObject?
        self.message = dictionary["message"] as? String ??  self.error?["message"] as? String ??
            self.data?.value(forKey:"message") as? String
        self.message_description = dictionary["description"] as? String ?? self.error?["description"] as? String ??  self.main_response?["error_description"] as? String ?? self.message
        self.success = !isError
        
        
    }
    
}






