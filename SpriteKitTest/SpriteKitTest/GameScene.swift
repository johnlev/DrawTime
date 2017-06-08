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
    var pathScene = DrawNode()
    
    override func didMove(to view: SKView) {
        pathScene = DrawNode(view: view)
        pathScene.position = view.frame.origin
        self.addChild(pathScene)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else {
            return
        }
        self.pathScene.touchDown(atPoint: t.location(in: self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else {
            return
        }
        self.pathScene.touchMoved(toPoint: t.location(in: self))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else {
            return
        }
        self.pathScene.touchUp(atPoint: t.location(in: self))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else {
            return
        }
        self.pathScene.touchUp(atPoint: t.location(in: self))
    }
}
