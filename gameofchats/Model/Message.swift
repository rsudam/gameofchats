//
//  Message.swift
//  gameofchats
//
//  Created by Raghu Sairam on 24/10/18.
//  Copyright © 2018 Raghu Sairam. All rights reserved.
//

import Foundation
import Firebase

class Message: NSObject {
    @objc var fromId: String?
    @objc var toID: String?
    @objc var timeStamp: NSNumber?
    @objc var text: String?
    @objc var imageUrl: String?
    @objc var imageHeight: NSNumber?
    @objc var imageWidth: NSNumber?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toID : fromId
    }
    
    init(dictionary:[String: Any]){
        super.init()
        fromId = dictionary["fromId"] as? String
        
        toID = dictionary["toID"] as? String
        timeStamp = dictionary["timeStamp"] as? NSNumber
        text = dictionary["text"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        imageHeight = dictionary["imageHeight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
        
        
    }
}
