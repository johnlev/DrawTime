//
//  GameScene.swift
//  SpriteKitTest
//
//  Created by John Kotz on 6/7/17.
//  Copyright © 2017 Cheeky WWDC. All rights reserved.
//

import SpriteKit
import GameplayKit

class DrawNode: SKNode {
    // Store the path in a Bezier path
    private var path = UIBezierPath()
    // The line that will be drawn
    private var line = SKShapeNode()
    // Stores all previously made drawings
    private var nodes = [SKSpriteNode]()
    // All the points in this line
    private var points = [CGPoint]()
    
    // For custom texturization
    var containingView: SKView?
    
    /// Initialize
    override init() {
        super.init()
        self.addChild(line)
    }
    
    /// Provide custom view for texurizing
    init(view: SKView) {
        super.init()
        containingView = view
        self.addChild(line)
    }
    
    /// Fails. Dont call this
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Handles the touch down event
    func touchDown(atPoint pos : CGPoint) {
        // Add the point to the path and update the line
        path.move(to: pos)
        line.path = path.cgPath
        
        // Save the point
        points.append(pos)
        
        // Set up the line's style
        line.strokeColor = UIColor.red
        line.lineWidth = 3
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
        line.strokeColor = UIColor.yellow
        
        // Make a sprite of it
        let sprite = SKSpriteNode(texture: (self.containingView ?? SKView()).texture(from: line))
        sprite.position = CGPoint(x: line.frame.origin.x + line.frame.width / 2, y: line.frame.origin.y + line.frame.height / 2)
        nodes.append(sprite)
        self.addChild(sprite)
        
        // Reset the path and move the line on top of the new nodes
        path = UIBezierPath()
        line.path = path.cgPath
        line.zPosition += 1
        line.strokeColor = UIColor.red
    }
}

