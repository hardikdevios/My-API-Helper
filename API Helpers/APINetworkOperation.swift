//
//  HKoperationQueue.swift
//  AMChar+
//
//  Created by Theta on 6/2/16.
//  Copyright © 2016 Praxinfo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import HKKit
import netfox
open class APINetworkOperation: HKOperation {

    let URLString: String
    typealias handler = ((APIResponseData)->())?
    let responseHandler: handler
    var perams: [String:Any]?
    let method: Alamofire.HTTPMethod
    var body: String?
    weak var request: Alamofire.Request?
    fileprivate var maxRetry: Int = 1
    fileprivate var currentRetry = 0
    var base:APIWebserviceURL
    var type:APIType = .simple
    
    var lastID:String? {
        
        return self.URLString.hk_getLastComponent("/")
    }
    init(base:APIWebserviceURL,
         type:APIType,
         URLString: String,
         perams: [String:Any?]? = nil,
         method: Alamofire.HTTPMethod = .post,
         body: String? = nil, quality: QualityOfService?,
         block: handler = nil) {
        
        self.URLString = URLString
        self.responseHandler = block
        self.method = method
        self.base = base
        self.type = type
        super.init()
        self.perams = self.updatePerams(perams)
        self.body = body
        self.qualityOfService = quality ?? .background
        if self.qualityOfService != .background {
            self.queuePriority = .veryHigh
        }else{
            self.queuePriority = .veryLow
        }
        
    }
 
    
    public let sessionManger: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses?.insert(NFXProtocol.self, at: 0)
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        let manager = Alamofire.SessionManager(configuration: configuration)
        return manager
    }()
    
    func updatePerams(_ perams: [String:Any?]?)->[String:Any]? {

        return perams?.reduce([String: Any]()) { (dict, e) in
            
            if e.1 is APIFileData {
                var dict = dict
                dict[e.0] = e.1
                return dict
            }else {
                guard let data = e.1, let value = JSON(data).rawValue as Any? else { return dict}
                var dict = dict
                dict[e.0] = value
                return dict
            }

            

        }
    }

    override open func main() {
        
        API.sharedInstance.getRequestHeaders { (headers) in
            let requestConvertible = APIRequestConvertible.construct(base: base,
                                                                     type: type,
                                                                    encoding: nil,
                                                                    method,
                                                                    URLString,
                                                                    headers:headers,
                                                                    perms: perams,
                                                                    body: body)
            
            
            self.request = self.sessionManger.request(requestConvertible).response { response in
                
                self.validateResponseError(response:response)
                
                }.debugLog().responseSwiftyJSON {(request, response, json, error) -> Void in
                    
                    if Config.api_logging_enable {
                        debugPrint(json)
                    }
                    self.mainHandler(json.dictionaryObject, error: error)
                    
            }

        }
      
    }

 
    func validateResponseError(response: DefaultDataResponse) {
        
        if let code = response.response?.statusCode, code == 401 {

            HKQueue.main.execute({ () -> Void in
                
                if ENUM_USER.object != nil && !API.sharedInstance.operationsQueue.isSuspended {
                    Config.delegate.cleanAndResetDB(firstScreen: true, callback: {
                        
                        
                        BasicFunctions.displayAlert(Localizable("Your session is expired or invalid, Please login again"))
                    })

                }
            })
            
        }
    }

 
    func restart() {
        self.start()
    }

    fileprivate func mainHandler(_ response: [String:Any]?, error: NSError?) {

        currentRetry += 1
        if error != nil  && currentRetry < maxRetry {
            self.restart()
        } else {
            self.responseHandler?(APIResponseData(response: response, error: error, operation: self))

        }

    }
   
    override open func cancel() {
        currentRetry = maxRetry
        request?.cancel()
        super.cancel()

    }
}


extension DataRequest {
    public func debugLog() -> Self {
        #if DEBUG
            if Config.api_logging_enable {
                debugPrint("API Name ::::::::::::::::::", self.request!.url!, terminator: "\n\n")
                debugPrint(self)
                debugPrint(terminator:"\n\n")
            }

        #endif
        return self
    }

    @discardableResult
    public func responseSwiftyJSON(
        queue: DispatchQueue? = nil,
        options: JSONSerialization.ReadingOptions = .allowFragments,
        _ completionHandler:@escaping (URLRequest, HTTPURLResponse?, SwiftyJSON.JSON, NSError?) -> Void)
        -> Self {

            return response(queue: queue, responseSerializer: DataRequest.jsonResponseSerializer(options: options), completionHandler: { (response) in

                DispatchQueue.global(qos: .default).async(execute: {

                    var responseJSON: JSON
                    if response.result.isFailure {
                        responseJSON = JSON.null
                    } else {
                        responseJSON = SwiftyJSON.JSON(response.result.value!)

                    }
                    (queue ?? DispatchQueue.main).async(execute: {
                        completionHandler(response.request!, response.response, responseJSON, response.result.error as NSError?)
                    })
                })

            })

    }

}


