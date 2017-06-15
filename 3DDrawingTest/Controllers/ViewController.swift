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

class ViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    weak var dataEngine: DataEngine!
    
    var canvasTexture: SKScene = SKScene()
    var canvasNode = SCNNode()
    let pixelsPerMeter = CGFloat(1200)
    
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
        //sceneView.showsStatistics = true
        
        // set up the scene
        setupScene()
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
        sceneView.antialiasingMode = .multisampling4X
        sceneView.automaticallyUpdatesLighting = true
        
        sceneView.preferredFramesPerSecond = 60
    }
    
    // TODO: Add plane restart like demo application
    func restartPlaneDetection() {
    }
    
    fileprivate func setupPlane(at: SCNVector3) {
        
        // Set the scene to the view
        let scene = SCNScene()
        let light = SCNLight()
        light.color = UIColor.yellow
        light.type = SCNLight.LightType.omni
        //light.castsShadow = true
        light.spotInnerAngle = CGFloat(2 * Double.pi)
        
        drawNode = DrawNode(dataEngine: self.dataEngine)
        drawNode!.containingView = canvasTexture.view
        drawNode!.containingView = canvasTexture.view
        sceneView.scene = scene
        canvasTexture = SKScene(size: CGSize(width: extentx * pixelsPerMeter, height: extentz * pixelsPerMeter))
        canvasTexture.backgroundColor = UIColor.gray.withAlphaComponent(0.0)
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
        
        let background = SKSpriteNode(color: UIColor.gray.withAlphaComponent(0.5), size: canvasTexture.size)
        canvasTexture.addChild(background)
        background.run(SKAction.fadeAlpha(to: 0.0, duration: 3.0))
    }
}

extension ViewController: ARSCNViewDelegate {
    
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

// Might be needed later on
extension ViewController: ARSessionDelegate {}

extension ViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let coord = self.sceneView.hitTest((touches.first?.location(in: self.sceneView))!, options: nil)
        if coord.count > 0{
            let drawingCoord = CGPoint( x: coord[0].textureCoordinates(withMappingChannel: 0).x * extentx * pixelsPerMeter,
                                        y: coord[0].textureCoordinates(withMappingChannel: 0).y * extentz * pixelsPerMeter)
            self.drawNode!.touchDown(atPoint: drawingCoord)
            print(drawingCoord)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let coord = self.sceneView.hitTest((touches.first?.location(in: self.sceneView))!, options: nil)
        if coord.count > 0{
            let drawingCoord = CGPoint( x: coord[0].textureCoordinates(withMappingChannel: 0).x * extentx * pixelsPerMeter,
                                        y: coord[0].textureCoordinates(withMappingChannel: 0).y * extentz * pixelsPerMeter)
            self.drawNode!.touchMoved(toPoint: drawingCoord)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let coord = self.sceneView.hitTest((touches.first?.location(in: self.sceneView))!, options: nil)
        if coord.count > 0{
            let drawingCoord = CGPoint( x: coord[0].textureCoordinates(withMappingChannel: 0).x * extentx * pixelsPerMeter,
                                        y: coord[0].textureCoordinates(withMappingChannel: 0).y * extentz * pixelsPerMeter)
            self.drawNode!.touchUp(atPoint: drawingCoord)
        }
    }
}
