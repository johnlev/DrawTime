//
//  DataEngine.swift
//  SpriteKitTest
//
//  Created by Christopher Schlitt on 6/8/17.
//  Copyright © 2017 Cheeky WWDC. All rights reserved.
//

import Foundation
import SpriteKit
import MultipeerConnectivity

class DataEngine: NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    
    // Data
    var nodes = NodeStack()
    var delegate: DataEngineDelegate!
    
    // Connectivity
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    
    // Initialization
    override init(){
        print("Starting the engine")
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: "drawing-service")
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: "drawing-service")
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    // Connection Methods - Advertising
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        print("Received invitation from peer")
        
        // Connect to the peer
        invitationHandler(true, self.session)
    }
    
    // Connection Methods - Connecting
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        print("Found a peer")
        
        // Invite the peer
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // TODO
        print("Lost a peer")
    }
    
    // Connection Methods - Data
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("peer \(peerID) didChangeState: \(state)")
        
        // TODO: Send all previous drawings to user
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceiveData: \(data)")
        
        // Extract Node
        let receivedNode = NSKeyedUnarchiver.unarchiveObject(with: data) as! SKSpriteNode
        
        // Save the Node
        self.nodes.push(receivedNode)
        
        // Draw the Node
        self.delegate.drawNode(receivedNode)
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("didFinishReceivingResourceWithName")
    }
    
    
    // Node handling methods - Custom
    func sendNode(_ node: SKSpriteNode){
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: node)
        do {
            try self.session.send(dataToSend, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
        }
        catch let error {
            print("Error for sending: \(error)")
        }
    }
    
}

/*
 Protocol to allow saving and receiving drawings
 */
@objc protocol DataEngineDelegate: class {
    // Called when a peer sends a drawing that should be shown
    func drawNode(_ node: SKSpriteNode)
    // Called when a peer sends a node (TODO)
    @objc optional func removeNode(_ node: SKSpriteNode)
}
