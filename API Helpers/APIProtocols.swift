//
//  APIProtocols.swift
//  E-Scooter
//
//  Created by Hardik Shah on 25/02/18.
//  Copyright © 2018 Theatechnolabs. All rights reserved.
//

import Foundation
import UIKit

protocol APIFileProtocol {
    
    var image: UIImage { get set }
    var key: String { get set }
    var compression: CGFloat { get set }
    var mimeType: String { get set }
    var extensionName: String { get set }

}

class APIFileData:APIFileProtocol{
  
    
    var image: UIImage
    var key: String
    var compression: CGFloat
    var mimeType: String
    var extensionName: String
    
    init(image:UIImage,key:String,compression:CGFloat,mimeType:String,extensionName:String = ".jpg") {
        self.image = image
        self.key = key
        self.compression = compression
        self.mimeType = mimeType
        self.extensionName = extensionName
    }
    
    
}
