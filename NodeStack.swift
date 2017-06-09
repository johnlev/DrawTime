//
//  NodeStack.swift
//  SpriteKitTest
//
//  Created by Christopher Schlitt on 6/8/17.
//  Copyright © 2017 Cheeky WWDC. All rights reserved.
//

import Foundation
import SpriteKit

struct NodeStack {
    var items = [SKSpriteNode]()
    
    mutating func push(_ node: SKSpriteNode) {
        items.append(node)
    }
    
    mutating func pop() -> SKSpriteNode {
        return items.removeLast()
    }
    
    mutating func peek() -> SKSpriteNode {
        return items.last!
    }
    
    mutating func isEmpty() -> Bool {
        return 0 == items.count
    }
    
    mutating func removeAtIndex(_ index: Int){
        
        for i in index+1..<items.count {
            items[i-1] = items[i]
        }
        
        items.removeLast()
    }
}

