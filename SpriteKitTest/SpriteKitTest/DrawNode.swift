//
//  GameScene.swift
//  SpriteKitTest
//
//  Created by John Kotz on 6/7/17.
//  Copyright © 2017 Cheeky WWDC. All rights reserved.
//

import SpriteKit
import GameplayKit
import MultipeerConnectivity

class DrawNode: SKNode, DataEngineDelegate {
    
    // Store the path in a Bezier path
    private var path = UIBezierPath()
    // The line that will be drawn
    private var line = SKShapeNode()
    // Stores all previously made drawings
    private var nodes = [SKSpriteNode]()
    // All the points in this line
    private var points = [CGPoint]()
    var lineWidth = CGFloat(10)
    
    private var dataEngine: DataEngine
    var delegate: DrawNodeDelegate!

    var color = UIColor.yellow
    var userName: String!
    
    // For custom texturization
    var containingView: SKView?
    
    /// Initialize
    init(name: String, color: UIColor) {
        
        self.dataEngine = DataEngine(name: name, color: color)
        
        
        super.init()
        self.name = name
        self.color = color
        self.dataEngine.delegate = self
        self.addChild(line)
    }
    
    /// Provide custom view for texurizing
    init(view: SKView, name: String, color: UIColor) {
        self.dataEngine = DataEngine(name: name, color: color)
        
        super.init()
        self.name = name
        self.color = color
        self.dataEngine.delegate = self
        containingView = view
        self.addChild(line)
    }
    
    /// Fails. Dont call this
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func drawNode(points: [CGPoint], color: UIColor) {
        // self.addChild(node)
        self.drawPath(pointsToDraw: points, color: color)
    } 

    /// Handles the touch down event
    func touchDown(atPoint pos : CGPoint) {
        // Add the point to the path and update the line
        path.move(to: pos)
        line.path = path.cgPath
        
        // Save the point
        points.append(pos)
        
        // Set up the line's style
        line.strokeColor = color
        line.lineWidth = lineWidth
    }
    
    /// Handles the touch move event
    func touchMoved(toPoint pos : CGPoint) {
        // Add the point to the path and update the line
        path.addLine(to: pos)
        line.path = path.cgPath
        // Save...
        points.append(pos)
    }
    
    /// Handles the touch up event
    func touchUp(atPoint pos : CGPoint) {
        path.addLine(to: pos)
        line.path = path.cgPath
        points.append(pos)
        
        // Called to legitimitize the drawing
        self.competePath()
    }
    
    func competePath() {
        // Yellow to indicate that it is a node
        self.dataEngine.color = self.color
        self.dataEngine.sendNode(points)
        self.drawPath(pointsToDraw: points, color: self.color)
    }
    
    func drawPath(pointsToDraw: [CGPoint], color: UIColor){
        self.points = pointsToDraw
        let newLine = SKShapeNode(splinePoints: &points, count: pointsToDraw.count)
        newLine.lineWidth = lineWidth
        newLine.strokeColor = color
        
        // Make a sprite of it
        let sprite = SKSpriteNode(texture: (self.containingView ?? SKView()).texture(from: newLine))
        sprite.position = CGPoint(x: newLine.frame.origin.x + newLine.frame.width / 2, y: newLine.frame.origin.y + newLine.frame.height / 2)
        nodes.append(sprite)

        self.addChild(sprite)
        
        // Reset the path and move the line on top of the new nodes
        path = UIBezierPath()
        points = []
        line.path = path.cgPath
        line.zPosition += 1
        line.strokeColor = UIColor.red
    }
    
    func addUser(name: String, color: UIColor, peerID: MCPeerID) {
        self.delegate.addUser(name: name, color: color, peerID: peerID)
    }
    
    func removeUser(peerID: MCPeerID) {
        self.delegate.removeUser(peerID: peerID)
    }
}

protocol DrawNodeDelegate {
    func addUser(name: String, color: UIColor, peerID: MCPeerID)
    func removeUser(peerID: MCPeerID)
}
