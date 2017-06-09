//
//  GameScene.swift
//  SpriteKitTest
//
//  Created by John Kotz on 6/7/17.
//  Copyright © 2017 Cheeky WWDC. All rights reserved.
//

import SpriteKit
import GameplayKit

class DrawNode: SKNode, DataEngineDelegate {
    
    // Store the path in a Bezier path
    private var path = UIBezierPath()
    // The line that will be drawn
    private var line = SKShapeNode()
    // Stores all previously made drawings
    private var nodes = [SKSpriteNode]()
    // All the points in this line
    private var points = [CGPoint]()
    
    private var dataEngine = DataEngine()

    var color = UIColor.yellow
    var userName: String!
    
    // For custom texturization
    var containingView: SKView?
    
    /// Initialize
    override init() {
        super.init()
        self.dataEngine.delegate = self
        self.dataEngine.name = self.userName
        self.dataEngine.color = self.color
        self.addChild(line)
    }
    
    /// Provide custom view for texurizing
    init(view: SKView) {
        super.init()
        self.dataEngine.delegate = self
        self.dataEngine.name = self.userName
        self.dataEngine.color = self.color
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
        line.strokeColor = UIColor.red
        line.lineWidth = 5
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
        self.dataEngine.sendNode(points)
        self.drawPath(pointsToDraw: points, color: self.color)
    }
    
    func drawPath(pointsToDraw: [CGPoint], color: UIColor){
        self.points = pointsToDraw
        let newLine = SKShapeNode(splinePoints: &points, count: pointsToDraw.count)
        newLine.lineWidth = 5
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
}

