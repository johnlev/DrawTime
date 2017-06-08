//
//  GameScene.swift
//  SpriteKitTest
//
//  Created by John Kotz on 6/7/17.
//  Copyright © 2017 Cheeky WWDC. All rights reserved.
//

import SpriteKit
import GameplayKit

class PathNode: SKNode {
    private var path = UIBezierPath()
    private var line = SKShapeNode()
    private var nodes = [SKSpriteNode]()
    private var points = [CGPoint]()
    private var first = true
    
    override init() {
        super.init()
        self.addChild(line)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func touchDown(atPoint pos : CGPoint) {
        path.move(to: pos)
        line.path = path.cgPath
        line.strokeColor = UIColor.red
        points.append(pos)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        path.addLine(to: pos)
        line.path = path.cgPath
        points.append(pos)
    }
    
    func touchUp(atPoint pos : CGPoint) {
        path.addLine(to: pos)
        line.path = path.cgPath
        points.append(pos)
        
        self.competePath()
    }
    
    func competePath() {
        line.strokeColor = UIColor.yellow
        let sprite = SKSpriteNode(texture: self.scene?.view?.texture(from: line))
        sprite.position = CGPoint(x: line.frame.origin.x + line.frame.width / 2, y: line.frame.origin.y + line.frame.height / 2)
        nodes.append(sprite)
        self.addChild(sprite)
        
        path = UIBezierPath()
        line.path = path.cgPath
        line.zPosition += 1
        line.strokeColor = UIColor.red
    }
}

