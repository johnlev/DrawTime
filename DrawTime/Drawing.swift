//
//  Path.swift
//  DrawTime
//
//  Created by John Kotz on 6/7/17.
//  Copyright © 2017 Cheeky WWDC. All rights reserved.
//

import Foundation
import Realm

class DrawingPoint: Object {
    var rawValue: CGPoint!
    
    required init() {
        super.init()
    }
    
    init(value: CGRect) {
        super.init()
        self.rawValue = value
    }
}

class Drawing: Object {
    var points: List<DrawingPoints>!
}

class DrawingManager {
    let realm = try! Realm()
    
    func createDrawing(points: [CGPoint]) {
        let drawing = Drawing()
        
    }
    
    func saveDrawing(drawing: Drawing) {
        realm.write{
            realm.add(drawing)
        }
    }
}
