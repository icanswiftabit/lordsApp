//
//  Participant.swift
//  LordsApp
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import MultipeerConnectivity

final class Participant: Equatable {
    let peerID: MCPeerID
    var role: Role?
    
    init(peerID: MCPeerID) {
        self.peerID = peerID
    }
}

extension Participant: CustomStringConvertible {
    var description: String {
        return "peerID: \(peerID) role: \(role)"
    }
}

func == (lhs: Participant, rhs: Participant) -> Bool {
    return lhs.peerID == rhs.peerID
}
