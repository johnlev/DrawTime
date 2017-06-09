//
//  ContainerViewController.swift
//  3DDrawingTest
//
//  Created by Christopher Schlitt on 6/9/17.
//  Copyright © 2017 Taketomo Isazawa. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ContainerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, DrawingViewControllerDelegate {
    
    var color: UIColor!
    var name: String!
    
    var drawingUsers = [DrawingUser]()
    
    func addUser(name: String, color: UIColor, peerID: MCPeerID) {
        self.drawingUsers.append(DrawingUser(name: name, color: color, peerID: peerID))
        
        DispatchQueue.main.async {
            self.userCollectionView.reloadData()
        }
        
        
    }
    
    func removeUser(peerID: MCPeerID){
        for i in 0..<self.drawingUsers.count {
            if(self.drawingUsers[i].peerID == peerID){
                self.drawingUsers.remove(at: i)
            }
        }
        
        DispatchQueue.main.async {
            self.userCollectionView.reloadData()
        }
    }
    
    @IBOutlet weak var sceneView: UIView!
    @IBOutlet weak var userCollectionView: UICollectionView!
    
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.drawingUsers.count
    }
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.userCollectionView.dequeueReusableCell(withReuseIdentifier: "User Cell", for: indexPath) as! UserCell
        
        
        cell.nameLabel.text = self.drawingUsers[indexPath.row].name
        cell.colorView.backgroundColor = self.drawingUsers[indexPath.row].color
        
        
        
        cell.colorView.layer.cornerRadius = 7
        cell.colorView.layer.borderColor = UIColor.black.cgColor
        cell.colorView.layer.borderWidth = 1.0
        cell.layer.cornerRadius = 13
        cell.layer.borderColor = UIColor.darkText.cgColor
        cell.layer.borderWidth = 2.0
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.userCollectionView.delegate = self
        self.userCollectionView.dataSource = self
        
        self.drawingUsers.append(DrawingUser(name: self.name, color: self.color, peerID: MCPeerID(displayName: UIDevice.current.name)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationViewController = segue.destination as! ViewController
        destinationViewController.delegate = self
        destinationViewController.color = self.color
        destinationViewController.name = self.name
    }
 

}

class DrawingUser {
    let name: String
    let color: UIColor
    let peerID: MCPeerID
    
    init(name: String, color: UIColor, peerID: MCPeerID){
        self.name = name
        self.color = color
        self.peerID = peerID
    }
}
