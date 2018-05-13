//
//  File.swift
//  ZodiMatch
//
//  Created by Hardik on 18/01/18.
//  Copyright © 2018 Maitrey. All rights reserved.
//

import Foundation
public enum APIWebserviceURL{
    
    case rest
    case search
    case oauth
    
    public var baseURL:String {
        
        switch self {
        case .rest:
            
                return Config.api_url_prod
        case .oauth:
            
            return Config.api_url_oauth
        case .search:
            
            return Config.api_url_search

        }
    
        
    }
    
    public var host:String {
        
        guard  let host = self.baseURL.components(separatedBy: "://").last else {
            return ""
        }
        
        return host
        
    }
    
    
    
}


