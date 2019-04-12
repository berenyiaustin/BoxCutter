//
//  SettingsViewController.swift
//  BoxCutter
//
//  Created by Austin Berenyi on 4/11/19.
//  Copyright © 2019 Austin Berenyi. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController,UITextFieldDelegate {
    
    let defaults = UserDefaults.standard

    @IBOutlet weak var cutWarningTextField: BoxCutterTextField!
    @IBOutlet weak var fileNameSuffixTextField: BoxCutterTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cutWarningTextField.delegate = self
        fileNameSuffixTextField.delegate = self
        // Do any additional setup after loading the view.
        
        if let warning = defaults.string(forKey: "cutWarningText") {
            cutWarningTextField.text = warning
        }
        
        if let suffix = defaults.string(forKey: "fileNameSuffix") {
            fileNameSuffixTextField.text = suffix
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        cutWarningTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        cutWarningTextField.resignFirstResponder()
        print("done")
        
        if textField == cutWarningTextField {
            if let warning = cutWarningTextField.text {
                self.defaults.set(warning, forKey: "cutWarningText")
            }
        }
        if textField == fileNameSuffixTextField {
            if let suffix = fileNameSuffixTextField.text {
                self.defaults.set(suffix, forKey: "fileNameSuffix")
            }
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
