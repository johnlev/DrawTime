//
//  GameScene.swift
//  SpriteKitTest
//
//  Created by John Kotz on 6/7/17.
//  Copyright © 2017 Cheeky WWDC. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var spinnyNode : SKShapeNode?
    private var lastDrawn: CGPoint?
    private var lastDir: CGVector?
    private var path = CGMutablePath()
    private var line = SKShapeNode()
    private var nodes = [SKSpriteNode]()
    private var points = [CGPoint]()
    
    override func didMove(to view: SKView) {
        line.path = path
        line.strokeColor = UIColor.red
        self.addChild(line)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        let delta = lastDrawn != nil ? abs(lastDrawn!.x - pos.x) + abs(lastDrawn!.y - pos.y) : nil
        
        if delta == nil || delta! > 15 {
            path.move(to: pos)
            line.path = path
            points.append(pos)
            lastDrawn = pos
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        let delta = lastDrawn != nil ? abs(lastDrawn!.x - pos.x) + abs(lastDrawn!.y - pos.y) : nil
        
        if delta == nil || delta! > 15 {
            path.addLine(to: pos)
            line.path = path
            points.append(pos)
            lastDrawn = pos
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        let delta = lastDrawn != nil ? abs(lastDrawn!.x - pos.x) + abs(lastDrawn!.y - pos.y) : nil
        
        if delta == nil || delta! > 15 {
            path.addLine(to: pos)
            line.path = path
            points.append(pos)
            lastDrawn =  nil
        }
        
        self.competePath()
    }
    
    func competePath() {
        line.strokeColor = UIColor.yellow
        let sprite = SKSpriteNode(texture: self.view?.texture(from: line))
        sprite.position = CGPoint(x: line.frame.origin.x + line.frame.width / 2, y: line.frame.origin.y + line.frame.height / 2)
        nodes.append(sprite)
        self.addChild(sprite)
        
        path = CGMutablePath()
        line.path = path
        line.zPosition += 1
        line.strokeColor = UIColor.red
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else {
            return
        }
        self.touchDown(atPoint: t.location(in: self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else {
            return
        }
        self.touchMoved(toPoint: t.location(in: self))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else {
            return
        }
        self.touchUp(atPoint: t.location(in: self))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else {
            return
        }
        self.touchUp(atPoint: t.location(in: self))
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
