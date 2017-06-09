//
//  ViewController.swift
//  ARTest
//
//  Created by Taketomo Isazawa on 5/6/17.
//  Copyright © 2017 Taketomo Isazawa. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import ARKit
import Foundation
import MultipeerConnectivity

class ViewController: UIViewController, ARSCNViewDelegate, DrawNodeDelegate {
    func addUser(name: String, color: UIColor, peerID: MCPeerID) {
        self.delegate.addUser(name: name, color: color, peerID: peerID)
    }
    func removeUser( peerID: MCPeerID) {
        self.delegate.removeUser(peerID: peerID)
    }
    
    var name: String!
    var color: UIColor!
    var delegate: DrawingViewControllerDelegate!
    
    var drawNode: DrawNode!
    var canvasTexture: SKScene = SKScene()
    var canvasNode = SCNNode()
    let extent = CGFloat(1200)
    // TODO: Convert canvasTexture into a let that's set ini init
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        let scene = SCNScene()
        let light = SCNLight()
        light.color = UIColor.green
        light.type = SCNLight.LightType.omni
        //light.castsShadow = true
        light.spotInnerAngle = CGFloat(2 * Double.pi)
        
        sceneView.scene = scene
        canvasTexture = SKScene(size: CGSize(width: extent, height: extent))
//        canvasTexture.backgroundColor = UIColor.clear
        
        drawNode = DrawNode(name: self.name, color: self.color)
        
        drawNode.position = CGPoint(x:0.0, y:0.0)
        drawNode.color = self.color
        drawNode.delegate = self
        
        switch self.color {
        case UIColor.yellow:
            print("initially Yellow")
        case UIColor.red:
            print("initially Red")
        case UIColor.blue:
            print("initially Blue")
        case UIColor.green:
            print("initially Green")
        default:
            print("initially Yellow")
        }
        
        
        drawNode.userName = self.name
        drawNode.containingView = canvasTexture.view
        canvasTexture.addChild(drawNode)
        let canvasGeometry = SCNPlane()
        canvasGeometry.height = 1.0
        canvasGeometry.width = 1.0
        canvasGeometry.firstMaterial?.diffuse.contents = canvasTexture
        canvasGeometry.firstMaterial?.isDoubleSided = true
        canvasNode.geometry = canvasGeometry
        canvasNode.position = SCNVector3(0,0,-2.0)
        scene.rootNode.addChildNode(canvasNode)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    //    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    //        // This visualization covers only detected planes.
    //        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    //
    //        // Create a SceneKit plane to visualize the node using its position and extent.
    //        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
    //        let planeNode = SCNNode(geometry: plane)
    //        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
    //
    //        // SCNPlanes are vertically oriented in their local coordinate space.
    //        // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
    //        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
    //
    //        // ARKit owns the node corresponding to the anchor, so make the plane a child node.
    //        node.addChildNode(planeNode)
    //    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let coord = self.sceneView.hitTest((touches.first?.location(in: self.sceneView))!, options: nil)
        if coord.count > 0{
            let drawingCoord = CGPoint( x: coord[0].textureCoordinates(withMappingChannel: 0).x * extent,
                                        y: coord[0].textureCoordinates(withMappingChannel: 0).y * extent)
            self.drawNode.touchDown(atPoint: drawingCoord)
            print(drawingCoord)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let coord = self.sceneView.hitTest((touches.first?.location(in: self.sceneView))!, options: nil)
        if coord.count > 0{
            let drawingCoord = CGPoint( x: coord[0].textureCoordinates(withMappingChannel: 0).x * extent,
                                        y: coord[0].textureCoordinates(withMappingChannel: 0).y * extent)
            self.drawNode.touchMoved(toPoint: drawingCoord)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let coord = self.sceneView.hitTest((touches.first?.location(in: self.sceneView))!, options: nil)
        if coord.count > 0{
            let drawingCoord = CGPoint( x: coord[0].textureCoordinates(withMappingChannel: 0).x * extent,
                                        y: coord[0].textureCoordinates(withMappingChannel: 0).y * extent)
            self.drawNode.touchUp(atPoint: drawingCoord)
        }
    }
    
}

protocol DrawingViewControllerDelegate {
    func addUser(name: String, color: UIColor, peerID: MCPeerID)
    func removeUser(peerID: MCPeerID)
}

