//
//  ContainerViewController.swift
//  3DDrawingTest
//
//  Created by Christopher Schlitt on 6/9/17.
//  Copyright © 2017 Taketomo Isazawa. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var color: UIColor!
    var name: String!
    
    @IBOutlet weak var sceneView: UIView!
    @IBOutlet weak var userCollectionView: UICollectionView!
    
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.userCollectionView.dequeueReusableCell(withReuseIdentifier: "User Cell", for: indexPath) as! UserCell
        cell.nameLabel.text = self.name
        cell.colorView.backgroundColor = self.color
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
        destinationViewController.color = self.color
    }
 

}
