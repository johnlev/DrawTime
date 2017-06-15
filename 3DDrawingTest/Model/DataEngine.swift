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

/// Protocol to allow managing the connection
@objc protocol DataEngineConnectionDelegate: class {
    // Called when peers connect and disconnect
    func addUser(name: String, color: UIColor, peerID: MCPeerID)
    func removeUser(peerID: MCPeerID)
    
}

/// Protocol to allow saving and receiving drawings
@objc protocol DataEngineDrawingDelegate: class {
    // Called when a peer sends a drawing that should be shown
    func drawNode(points: [CGPoint], color: UIColor)
    
}

class DataEngine: NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    
    // Data
    var nodes = [[CGPoint]]()
    weak var connectionDelegate: DataEngineConnectionDelegate?
    weak var drawingDelegate: DataEngineDrawingDelegate?
    var name: String!
    var color: UIColor!
    
    // Connectivity
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    
    // Initialization
    init(name: String, color: UIColor) {
        print("Starting the engine")
        
        self.name = name
        self.color = color
        
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
        
        // Send all previous drawings from this device to user
        if state == MCSessionState.connected {
            for node in self.nodes {
                self.sendNode(node)
            }
            self.addUser()
        } else if state == MCSessionState.notConnected {
            connectionDelegate?.removeUser(peerID: peerID)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceiveData: \(data)")
        
        // Extract Node Message
        let receivedNode = NSKeyedUnarchiver.unarchiveObject(with: data) as! DataPacket
        
        switch receivedNode.type {
        case "pointData":
            drawingDelegate?.drawNode(points: receivedNode.pointData, color: receivedNode.color)
        case "addUser":
            connectionDelegate?.addUser(name: receivedNode.name, color: receivedNode.color, peerID: peerID)
        default:
            break
        }
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
    
    func addUser(){
        let dataPacket = DataPacket()
        dataPacket.type = "addUser"
        dataPacket.name = self.name
        dataPacket.color = self.color
        
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dataPacket)
        do {
            try self.session.send(dataToSend, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
        }
        catch let error {
            print("Error for sending: \(error)")
        }
    }
    
    // Node handling methods - Custom
    func sendNode(_ node: [CGPoint]){
        
        self.nodes.append(node)
        
        let dataPacket = DataPacket()
        dataPacket.type = "pointData"
        dataPacket.pointData = node
        dataPacket.color = self.color
        
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dataPacket)
        print("Data Encoded")
        
        do {
            try self.session.send(dataToSend, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
        }
        catch let error {
            print("Error for sending: \(error)")
        }
    }
}

extension Data {
    init(reading input: InputStream) {
        self.init()
        input.open()
        
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            self.append(buffer, count: read)
        }
        buffer.deallocate(capacity: bufferSize)
        
        input.close()
    }
}
