//
//  File.swift
//  ZodiMatch
//
//  Created by Hardik on 18/01/18.
//  Copyright © 2018 Maitrey. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
enum APIRequestConvertible: URLRequestConvertible {
    
    case construct(
        base:APIWebserviceURL,
        type:APIType,
        encoding:Alamofire.ParameterEncoding?,
        Alamofire.HTTPMethod, String,
        headers:[String:String],
        perms:[String:Any]?,
        body:String?
    )
    
    
    func asURLRequest() throws -> URLRequest {
        let construct:(
            base:APIWebserviceURL,
            type:APIType,
            method: Alamofire.HTTPMethod,
            endPoint: String,
            encoding: Alamofire.ParameterEncoding,
            headers: [String:String],
            perms: [String:Any]?) = {
                
                switch self {
                case .construct(let base, let type,let encoding,let method, let endPoint, let header, let perms, let body):
                    return parseRequest(base: base, type: type, encoding:encoding, method: method, endPoint: endPoint, headers: header, perms: perms, body: body)
                    
                }
                
        }()
        
        
        
        let url = try construct.base.baseURL.asURL()
        
        var urlRequest =  NSMutableURLRequest(url: url.appendingPathComponent(construct.endPoint))
        urlRequest.httpMethod = construct.method.rawValue
        urlRequest.allHTTPHeaderFields = construct.headers
        
        urlRequest = try! (construct.encoding.encode(urlRequest, with: construct.perms) as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        
        if urlRequest.httpBody != nil {
            URLProtocol.setProperty(urlRequest.httpBody!, forKey: "NFXBodyData", in:urlRequest)
        }
        
        return urlRequest as URLRequest
        
    }
    
    
    private func parseRequest(base:APIWebserviceURL,
                              type:APIType,
                              encoding:Alamofire.ParameterEncoding?,
                              method: Alamofire.HTTPMethod,
                              endPoint: String,
                              headers: [String:String],
                              perms: [String:Any]?,
                              body:String?) -> (base:APIWebserviceURL,type:APIType,method: Alamofire.HTTPMethod, endPoint: String, encoding: Alamofire.ParameterEncoding, headers: [String:String], perms: [String:Any]?)
    {
        
        if type == .multipart_formdata {
            return (base, type, method, endPoint, MultipartEncoding(data: perms), headers, perms)
        }else if body != nil {
            return (base, type, method, endPoint, StringBodyEncoding(string: body!), headers, [:])
        }else if method == .post || method == .put {
            return (base, type, method, endPoint, encoding ?? JSONEncoding.default, headers, perms)
        }else{
            return (base, type, method, endPoint, encoding ?? URLEncoding.default, headers, perms)
        }
        
        
    }
    
}


struct StringBodyEncoding: ParameterEncoding {
    private let string: String
    
    init(string: String) {
        self.string = string
    }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = urlRequest.urlRequest
        urlRequest?.httpBody = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        return urlRequest!
    }
}


struct MultipartEncoding: ParameterEncoding {
    private let data: [String:Any?]?
    
    init(data: [String:Any?]?) {
        self.data = data
    }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = urlRequest.urlRequest
        let multipartData = MultipartFormData()
        
        self.data?.forEach({ (data) in
            if let value = data.value as? APIFileProtocol {
                multipartData.append(UIImageJPEGRepresentation(value.image, value.compression)!, withName: data.key , fileName:  UUID().uuidString + value.extensionName, mimeType: value.mimeType)
            }else{
                
                guard let mainData = data.1, let value = JSON(mainData).rawString(), let dataVal = value.data(using: .utf8) else { return }
                multipartData.append(dataVal, withName: data.key)
            }
        })
        
        
        urlRequest?.httpBody = try? multipartData.encode()
        urlRequest?.setValue(multipartData.contentType, forHTTPHeaderField: "Content-Type")
        return urlRequest!
    }
}
enum APIType {
    
    case simple
    case multipart_formdata
    
    
}
extension NSMutableURLRequest:URLRequestConvertible {
    
    public func asURLRequest() throws -> URLRequest {
        
        return self as URLRequest
        
    }
    
}
