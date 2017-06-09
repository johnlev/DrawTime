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
    // var nodes = NodeStack()
    var nodes = [[CGPoint]]()
    var delegate: DataEngineDelegate!
    var name: String!
    var color: UIColor!
    
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
    init(name: String, color: UIColor){
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
        if(state == MCSessionState.connected){
            for node in self.nodes {
                self.sendNode(node)
            }
            self.addUser()
        } else if(state == MCSessionState.notConnected){
            self.delegate.removeUser(peerID: peerID)
        }
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceiveData: \(data)")
        
        
        // Extract Node Message
        let receivedNode = NSKeyedUnarchiver.unarchiveObject(with: data) as! DataPacket
        
        switch receivedNode.type {
        case "pointData":
            self.delegate.drawNode(points: receivedNode.pointData, color: receivedNode.color)
        case "addUser":
            self.delegate.addUser(name: receivedNode.name, color: receivedNode.color, peerID: peerID)
        default:
            break
        }
        
        // self.delegate.drawNode(receivedNode)
        
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
        
        print("Attempting to Encode Data")
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dataPacket)
        print("Data Encoded")
        // let dataToSend = NSKeyedArchiver.archivedData(withRootObject: node)
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
        print("Attmepting to Encode Data")
        
        let dataPacket = DataPacket()
        dataPacket.type = "pointData"
        dataPacket.pointData = node
        
        
        switch self.color {
        case UIColor.yellow:
            print("Sending Yellow")
        case UIColor.red:
            print("Sending Red")
        case UIColor.blue:
            print("Sending Blue")
        case UIColor.green:
            print("Sending Green")
        default:
            print("Sending Yellow")
        }
        
        
        dataPacket.color = self.color
        
        print("Attempting to Encode Data")
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dataPacket)
        print("Data Encoded")
        // let dataToSend = NSKeyedArchiver.archivedData(withRootObject: node)
        do {
            try self.session.send(dataToSend, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
        }
        catch let error {
            print("Error for sending: \(error)")
        }
    }
    
}
/*
enum DataPacket {
    case name(String)
    case pointData([CGPoint])
    case color(UIColor)
}
*/

class DataPacket: NSObject, NSCoding {
    var name: String!
    var type: String!
    var pointData: [CGPoint]!
    var color: UIColor!
    
    override init() {
        
    }
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as? String ?? ""
        self.type = decoder.decodeObject(forKey: "type") as? String ?? ""
        self.pointData = decoder.decodeObject(forKey: "pointData") as? [CGPoint] ?? [CGPoint]()
        self.color = decoder.decodeObject(forKey: "color") as? UIColor ?? UIColor.yellow
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(type, forKey: "type")
        coder.encode(pointData, forKey: "pointData")
        coder.encode(color, forKey: "color")
    }
}



/*
 Protocol to allow saving and receiving drawings
 */
@objc protocol DataEngineDelegate: class {
    // Called when a peer sends a drawing that should be shown
    func drawNode(points: [CGPoint], color: UIColor)
    
    // Called when peers connect and disconnect
    func addUser(name: String, color: UIColor, peerID: MCPeerID)
    func removeUser(peerID: MCPeerID)
    
    // Called when a peer sends a node (TODO)
    @objc optional func removeNode(_ node: SKSpriteNode)
}
