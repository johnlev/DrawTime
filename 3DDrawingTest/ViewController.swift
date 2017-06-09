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

class ViewController: UIViewController, ARSCNViewDelegate {
    
    let astroUnit:CGFloat = 0.2
    let earthRadius:CGFloat = 0.01
    let drawNode: DrawNode = DrawNode()
    var canvasTexture: SKScene = SKScene()
    var canvasNode = SCNNode()
    let extent = CGFloat(600)
    // TODO: Convert canvasTexture into a let that's set ini init
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
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
        light.color = UIColor.yellow
        light.type = SCNLight.LightType.omni
        //light.castsShadow = true
        light.spotInnerAngle = CGFloat(2 * Double.pi)
        
        sceneView.scene = scene
        canvasTexture = SKScene(size: CGSize(width: extent, height: extent))
        canvasTexture.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.1)
        drawNode.position = CGPoint(x:0.0, y:0.0)
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
        
//        self.undoButton.isEnabled = self.drawNode.undoManaging.canUndo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        
    }
    
    @IBAction func undoPressed(_ sender: Any) {
        self.drawNode.undo()
//        self.undoButton.isEnabled = self.drawNode.undoManaging.canUndo
    }
    
    @IBAction func clearPressed(_ sender: Any) {
        self.drawNode.clear()
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
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let coord = self.sceneView.hitTest((touches.first?.location(in: self.sceneView))!, options: nil)
        if coord.count > 0{
            let drawingCoord = CGPoint( x: coord[0].textureCoordinates(withMappingChannel: 0).x * extent,
                                        y: coord[0].textureCoordinates(withMappingChannel: 0).y * extent)
            self.drawNode.touchUp(atPoint: drawingCoord)
//            self.undoButton.isEnabled = self.drawNode.undoManaging.canUndo
        }
    }
    
}

extension SCNVector3{
    static func fromRadial(r:Double, theta:Double, inclination:Double) -> SCNVector3 {
        let thetaRad = theta * M_PI / 180.0
        let inclinationRad = inclination * M_PI / 180.0
        let rho = r * cos(inclinationRad)
        let z = r * sin(inclinationRad)
        let x = rho * cos(thetaRad)
        let y = rho * sin(thetaRad)
        return SCNVector3(x, y, z)
    }
    
    static func initialLocation(r: Double, inclination: Double) -> SCNVector3{
        return SCNVector3.fromRadial(r: r, theta: 0.0, inclination: inclination)
    }
    
    static func omega(T: Double, inclination: Double) -> SCNVector3{
        let z = sin(inclination * Double.pi/180.0)/T
        let y = (1) * cos(inclination * Double.pi/180.0)/T
        return SCNVector3(0.0, y, z)
    }
}

