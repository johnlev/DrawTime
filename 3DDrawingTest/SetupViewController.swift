//
//  SetupViewController.swift
//  3DDrawingTest
//
//  Created by Christopher Schlitt on 6/8/17.
//  Copyright © 2017 Taketomo Isazawa. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var name: String!
    var color: UIColor!
    
    @available(iOS 2.0, *)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @available(iOS 2.0, *)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return "Yellow"
        case 1:
            return "Red"
        case 2:
            return "Blue"
        case 3:
            return "Green"
        default:
            return "Yellow"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var colorPicker: UIPickerView!
    
    @IBAction func joinButtonPressed(_ sender: Any) {
        let colorIndex = self.colorPicker.selectedRow(inComponent: 0)
        color = UIColor.yellow
        name = self.nameTextField.text!
        
        switch colorIndex {
        case 0:
            color = UIColor.yellow
        case 1:
            color = UIColor.red
        case 2:
            color = UIColor.blue
        case 3:
            color = UIColor.green
        default:
            color = UIColor.yellow
        }
        
        print("Setting color to: \(colorIndex)")
        
        self.performSegue(withIdentifier: "Go To BalckBoard Segue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.colorPicker.delegate = self
        self.colorPicker.dataSource = self
        self.nameTextField.delegate = self
        
        
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
        
        
        let destinationController = segue.destination as! ContainerViewController
        
        destinationController.name = self.name
        destinationController.color = self.color
        
    }
    

}
