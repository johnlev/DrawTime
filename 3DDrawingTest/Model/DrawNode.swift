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

// Storage Container for Node Queue
class DrawNodeData {
    
    let color: UIColor
    var points: [CGPoint]
    let lineWidth = CGFloat(10)
    
    init(color: UIColor, points: [CGPoint]){
        self.color = color
        self.points = points
    }
    
}

class DrawNode: SKNode, DataEngineDrawingDelegate {
    
    // Store the path in a Bezier path
    private var path = UIBezierPath()
    // The line that will be drawn
    private var line = SKShapeNode()
    // Stores all previously made drawings
    private var nodes = [SKSpriteNode]()
    // Stores upcoming drawings
    private var nodeQueue = [DrawNodeData]()
    private var currentNode: DrawNodeData!
    // Boolean indicating a draw is in progress
    private var isDrawing = false
    
    
    private weak var dataEngine: DataEngine!
    
    // For custom texturization
    var containingView: SKView?
    
    /// Initialize
    init(dataEngine: DataEngine) {
        
        self.dataEngine = dataEngine
        
        super.init()
        self.dataEngine.drawingDelegate = self
        self.addChild(line)
    }
    
    /// Provide custom view for texurizing
    init(view: SKView, dataEngine: DataEngine) {
        
        self.dataEngine = dataEngine
        
        super.init()
        self.dataEngine.drawingDelegate = self
        containingView = view
        self.addChild(line)
    }
    
    /// Fails. Dont call this
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawNode(points: [CGPoint], color: UIColor) {
        self.drawPath(DrawNodeData(color: color, points: points))
    } 

    /// Handles the touch down event
    func touchDown(atPoint pos: CGPoint) {
        // Start the draw
        self.isDrawing = true
        self.currentNode = DrawNodeData(color: self.dataEngine.color, points: [CGPoint]())
        
        // Add the point to the path and update the line
        path.move(to: pos)
        line.path = path.cgPath
        
        // Save the point
        self.currentNode.points.append(pos)
    }
    
    /// Handles the touch move event
    func touchMoved(toPoint pos: CGPoint) {
        // Add the point to the path and update the line
        path.addLine(to: pos)
        line.path = path.cgPath
        // Save...
        self.currentNode.points.append(pos)
    }
    
    /// Handles the touch up event
    func touchUp(atPoint pos: CGPoint) {
        path.addLine(to: pos)
        line.path = path.cgPath
        self.currentNode.points.append(pos)
        
        // Called to legitimitize the drawing
        self.competePath(self.currentNode)
        self.isDrawing = false
    }
    
    func competePath(_ nodeData: DrawNodeData) {
        // Yellow to indicate that it is a node
        self.dataEngine.sendNode(nodeData.points)
        self.drawPath(nodeData)
    }
    
    func drawPath(_ nodeData: DrawNodeData){
        let newLine = SKShapeNode(splinePoints: &nodeData.points, count: nodeData.points.count)
        newLine.lineWidth = nodeData.lineWidth
        newLine.strokeColor = nodeData.color
        
        // Make a sprite of it
        let sprite = SKSpriteNode(texture: (self.containingView ?? SKView()).texture(from: newLine))
        sprite.position = CGPoint(x: newLine.frame.origin.x + newLine.frame.width / 2, y: newLine.frame.origin.y + newLine.frame.height / 2)
        nodes.append(sprite)

        self.addChild(sprite)
        
        // Reset the path and move the line on top of the new nodes
        path = UIBezierPath()
        self.currentNode = DrawNodeData(color: self.dataEngine.color, points: [CGPoint]())
        line.path = path.cgPath
        line.zPosition += 1
        line.strokeColor = self.dataEngine.color
        
        if(self.nodeQueue.count > 0){
            let nextNode = self.nodeQueue.removeFirst()
            self.drawPath(nextNode)
        }
    }
}
