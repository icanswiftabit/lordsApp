//
//  RoleMessage.swift
//  LordsApp
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

struct RoleMessage: Sendable {
    let role: Role
    var type: MessageType {
        return .role
    }
    
    var data: Data {
        let dictionary: [String: Any] = ["type": type.rawValue,
                                         "content":[
                                            "role": role.rawValue
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: dictionary, options: [])
    }
    
    init(dictionary: [String: Any]) {
        self.role = Role(rawValue: dictionary["role"] as! String)!
    }
    
    init(role: Role) {
        self.role = role
    }
}
