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

class ViewController: UIViewController, DrawNodeDelegate {
    
    func addUser(name: String, color: UIColor, peerID: MCPeerID) {
        self.delegate.addUser(name: name, color: color, peerID: peerID)
    }
    func removeUser( peerID: MCPeerID) {
        self.delegate.removeUser(peerID: peerID)
    }
    
    var name: String!
    var color: UIColor!
    var delegate: DrawingViewControllerDelegate!
    
    var canvasTexture: SKScene = SKScene()
    var canvasNode = SCNNode()
    let extent = CGFloat(1200)
    // TODO: Convert canvasTexture into a let that's set ini init
    @IBOutlet var sceneView: ARSCNView!
    
    var extentx = CGFloat(0.6)
    var extentz = CGFloat(0.6)
    
    let session = ARSession()
    var sessionConfig = ARWorldTrackingSessionConfiguration()
    
    var drawNode: DrawNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        setupScene()
        
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
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.delegate = self
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func setupScene() {
        sceneView.delegate = self
        sceneView.session = session
    }
    
    func restartPlaneDetection() {
        
    }
    
    
    fileprivate func setupPlane(at: SCNVector3) {
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        let scene = SCNScene()
        let light = SCNLight()
        light.color = UIColor.yellow
        light.type = SCNLight.LightType.omni
        //light.castsShadow = true
        light.spotInnerAngle = CGFloat(2 * Double.pi)
        
        drawNode = DrawNode(name: self.name, color: self.color)
        drawNode!.userName = self.name
        drawNode!.color = self.color
        drawNode!.containingView = canvasTexture.view
        drawNode!.containingView = canvasTexture.view
        sceneView.scene = scene
        canvasTexture = SKScene(size: CGSize(width: extentx * 600, height: extentz * 600))
        canvasTexture.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        drawNode!.position = CGPoint(x:0.0, y:0.0)
        canvasTexture.addChild(drawNode!)
        
        let canvasGeometry = SCNPlane()
        canvasGeometry.height = extentz
        canvasGeometry.width = extentx
        canvasGeometry.firstMaterial?.diffuse.contents = canvasTexture
        canvasGeometry.firstMaterial?.isDoubleSided = true
        canvasNode.geometry = canvasGeometry
        canvasNode.position = at
        canvasNode.eulerAngles = SCNVector3(Double.pi/2, 0, 0)
        scene.rootNode.addChildNode(canvasNode)
        
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
    
}

extension ViewController: ARSCNViewDelegate {
    
    //    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    //        print("TRIGGERED")
    //    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // This visualization covers only detected planes.
        print("**Plane detected!")
        if drawNode == nil{
            DispatchQueue.main.async {
                guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
                
                // Create a SceneKit plane to visualize the node using its position and extent.
                let location = SCNVector3.positionFromTransform(planeAnchor.transform)
                self.extentz = CGFloat(planeAnchor.extent.z * 10)
                self.extentx = CGFloat(planeAnchor.extent.x * 10)
                self.setupPlane(at: location)
                print(String(describing: location), String(describing: self.extentx), String(describing:self.extentz))
            }
        }
        
    }
}

extension ViewController: ARSessionDelegate{
    
}

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let coord = self.sceneView.hitTest((touches.first?.location(in: self.sceneView))!, options: nil)
        if coord.count > 0{
            let drawingCoord = CGPoint( x: coord[0].textureCoordinates(withMappingChannel: 0).x * extentx * 600,
                                        y: coord[0].textureCoordinates(withMappingChannel: 0).y * extentz * 600)
            self.drawNode!.touchDown(atPoint: drawingCoord)
            print(drawingCoord)
        }
        //        else{
        //            self.setupPlane(at: SCNVector3(-0.5, -0.5, 0.0))
        //        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let coord = self.sceneView.hitTest((touches.first?.location(in: self.sceneView))!, options: nil)
        if coord.count > 0{
            let drawingCoord = CGPoint( x: coord[0].textureCoordinates(withMappingChannel: 0).x * extentx * 600,
                                        y: coord[0].textureCoordinates(withMappingChannel: 0).y * extentz * 600)
            self.drawNode!.touchMoved(toPoint: drawingCoord)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let coord = self.sceneView.hitTest((touches.first?.location(in: self.sceneView))!, options: nil)
        if coord.count > 0{
            let drawingCoord = CGPoint( x: coord[0].textureCoordinates(withMappingChannel: 0).x * extentx * 600,
                                        y: coord[0].textureCoordinates(withMappingChannel: 0).y * extentz * 600)
            self.drawNode!.touchUp(atPoint: drawingCoord)
        }
    }
}

protocol DrawingViewControllerDelegate {
    func addUser(name: String, color: UIColor, peerID: MCPeerID)
    func removeUser(peerID: MCPeerID)
}

