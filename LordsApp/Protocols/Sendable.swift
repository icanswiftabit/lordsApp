//
//  Sendable.swift
//  LordsApp
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

enum MessageType: String {
    case role, estimation, startEstimation, endEstimation
}

protocol Sendable {
    var type: MessageType { get }
    var data: Data { get }
    init(dictionary: [String: Any])
}
