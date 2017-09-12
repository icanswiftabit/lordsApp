//
//  FibonacciServiceProvider.swift
//  LordsApp
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import MultipeerConnectivity

enum FibonacciServiceError: Error {
    case pmAlreadyInSession(String)
    case noParticipants(String)
}

final class FibonacciServiceProvider: NSObject {
 
    fileprivate let serviceName = "fi-service"
    fileprivate var advertiser: MCNearbyServiceAdvertiser
    fileprivate let browser: MCNearbyServiceBrowser
    fileprivate let peerId: MCPeerID
    var participants = [Participant]()
    lazy var session: MCSession = {
        let session = MCSession(peer: self.peerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    weak var delegate: FibonacciServiceProviderDelegate?
    
    init(with displayName: String) {
        peerId = MCPeerID(displayName: displayName)
        advertiser = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: serviceName)
        browser = MCNearbyServiceBrowser(peer: peerId, serviceType: serviceName)
        
        super.init()
        
        advertiser.delegate = self
        browser.delegate = self
        
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }
    
    deinit {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
    }
    
    func send(_ role: Role) throws {
        guard participants.count > 0 else {
            throw FibonacciServiceError.noParticipants("Nobody is connected")
        }
        
        let containPM = participants.contains { $0.role == .pm }
        guard !containPM else {
            throw FibonacciServiceError.pmAlreadyInSession("Session already have a PM")
        }
        
        
        let msg = RoleMessage(role: role)
        try session.send(msg.data, toPeers: session.connectedPeers, with: .reliable)
        browser.stopBrowsingForPeers()
    }
}

extension FibonacciServiceProvider: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, session)
    }
}

extension FibonacciServiceProvider: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("foundPeer: \(peerID)")
        print("invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer: \(peerID)")
    }
}
extension FibonacciServiceProvider: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("peer \(peerID) didChangeState: \(state.rawValue)")
        switch state {
        case .connected:
            handleConnected(peerID)
        case .notConnected:
            handleDisconnected(peerID)
        default: break
        }
        delegate?.provider(self, participantsHaveChanged: participants)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceiveData: \(data)")
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        let messageTyp = MessageType(rawValue: json["type"] as! String)!
        switch messageTyp {
        case .role:
            //handle role
            let content = json["content"] as! [String: Any]
            let roleMessage = RoleMessage(dictionary: content)
            handle(roleMessage, from: peerID)
            delegate?.provider(self, participantsHaveChanged: participants)
        default:
            print("unexpected message type")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        print("didFinishReceivingResourceWithName")
    }
    
}

fileprivate extension FibonacciServiceProvider {
    
    func handleConnected(_ peerID: MCPeerID) {
        let participant = Participant(peerID: peerID)
        guard !participants.contains(participant) else { return }
        participants.append(participant)
    }
    
    func handleDisconnected(_ peerID: MCPeerID) {
        let participant = Participant(peerID: peerID)
        guard participants.contains(participant) else { return }
        participants.append(participant)
    }
    
    func handle(_ roleMessage: RoleMessage, from peerID: MCPeerID) {
        participants.forEach { print($0) }
        let participant = findParticipant(with: peerID)
        participant?.role = roleMessage.role
        participants.forEach { print($0) }
    }
    
    func findParticipant(with peerID: MCPeerID) -> Participant? {
        for participant in participants where participant.peerID == peerID {
            return participant
        }
        return nil
    }
}
