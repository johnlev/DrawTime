//
//  DataPacket.swift
//  3DDrawingTest
//
//  Created by Matthew Spear on 13/06/2017.
//  Copyright © 2017 Taketomo Isazawa. All rights reserved.
//

import UIKit

class DataPacket: NSObject, NSCoding {
    var name: String!
    var type: String!
    var pointData: [CGPoint]!
    var color: UIColor!
    
    override init() {}
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as? String ?? ""
        self.type = decoder.decodeObject(forKey: "type") as? String ?? ""
        self.pointData = decoder.decodeObject(forKey: "pointData") as? [CGPoint] ?? [CGPoint]()
        self.color = decoder.decodeObject(forKey: "color") as? UIColor ?? UIColor.yellow
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(type, forKey: "type")
        coder.encode(pointData, forKey: "pointData")
        coder.encode(color, forKey: "color")
    }
}
