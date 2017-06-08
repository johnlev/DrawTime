//
//  Map.swift
//  ARKitExample
//
//  Created by Matthew Spear on 07/06/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation

class Canvas: VirtualObject {
    
    override init() {
        super.init(modelName: "canvas", fileExtension: "scn", thumbImageFilename: "canvas", title: "Canvas")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
