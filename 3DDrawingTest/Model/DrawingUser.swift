//
//  DrawingUser.swift
//  3DDrawingTest
//
//  Created by Matthew Spear on 12/06/2017.
//  Copyright © 2017 Taketomo Isazawa. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class DrawingUser {
    
    let name: String
    let color: UIColor
    let peerID: MCPeerID
    
    init(name: String, color: UIColor, peerID: MCPeerID) {
        self.name = name
        self.color = color
        self.peerID = peerID
    }
}
