//
//  SetupViewController.swift
//  3DDrawingTest
//
//  Created by Christopher Schlitt on 6/8/17.
//  Copyright © 2017 Taketomo Isazawa. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var colorPicker: UIPickerView!
    
    var name: String!
    var color: UIColor!
    
    @available(iOS 2.0, *)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @available(iOS 2.0, *)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.nodeColor.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.nodeColor[row].name
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func joinButtonPressed(_ sender: Any) {
        let row = self.colorPicker.selectedRow(inComponent: 0)
        name = self.nameTextField.text ?? "👻"
        color = Constants.nodeColor[row].value
        print("Setting color to: \(row)")
        
        self.performSegue(withIdentifier: "Go To BalckBoard Segue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.colorPicker.delegate = self
        self.colorPicker.dataSource = self
        self.nameTextField.delegate = self
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationController = segue.destination as! ContainerViewController
        
        destinationController.name = self.name
        destinationController.color = self.color
    }
}
