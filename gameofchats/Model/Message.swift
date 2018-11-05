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
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toID : fromId
    }
}
