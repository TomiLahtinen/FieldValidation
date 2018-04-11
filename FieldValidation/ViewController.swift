//
//  ViewController.swift
//  FieldValidation
//
//  Created by Tomi Lahtinen on 10/04/2018.
//  Copyright © 2018 Tomi Lahtinen. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var moveButton: UIButton!
    
    let latitudeValidator = ViewController.createValidator(forRange: 90) // Latitudes between -90 ... 90
    let longitudeValidator = ViewController.createValidator(forRange: 180) // Longitudes between -180 ... 180
    
    // MARK:- IBAction implementations
    
    @IBAction func textFieldEdited(_ sender: UITextField) {
        doValidation()
    }
    
    @IBAction func moveTapped(_ sender: Any) {
        let location = CLLocationCoordinate2DMake(Double(latitudeField.text!)!,
                                                  Double(longitudeField.text!)!)
        let region = MKCoordinateRegionMake(location, MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0))
        mapView.setRegion(region, animated: true)
    }
    
   
    // MARK:- ViewController life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        moveButton.isEnabled = false
        
        latitudeField.delegate = self
        longitudeField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardShown), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardHidden), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    // MARK:- Private parts
    private func doValidation() {
        moveButton.isEnabled = latitudeValidator(latitudeField.text) && longitudeValidator(longitudeField.text)
    }
    
    @objc private func keyboardShown(notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardRect = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let buttonBottom = moveButton.frame.origin.y + moveButton.frame.size.height
                let keyBoardTop = view.frame.height - keyboardRect.cgRectValue.height
                let needToMoveUpBy = keyBoardTop - buttonBottom < 0 ? keyBoardTop - buttonBottom : 0
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                    self.view.frame.origin.y = (needToMoveUpBy)
                })
        }
    }
    
    @objc private func keyboardHidden(notification: Notification) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            self.view.frame.origin.y = 0
        })
    }
    
    /**
     * Create validator function that accepts optional string as a parameter
     * and return true if Double value represented by string is contained within
     * given Range
     */
    private static func createValidator(forRange range: Double) -> (String?) -> Bool {
        return { (string: String?) -> Bool in
            guard let string = string, // Mask optional by using same name
                  let asDouble = Double(string) // We now have unwrapped constant string instead of optional
                  else {
                     return false
            }
            return (-range...range).contains(asDouble) // Use closed range operator to form range and check if contains
        }
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        doValidation()
        // Never prevent editing even if validation fails
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        doValidation()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        doValidation()
        // Never prevent clearing even if validation fails
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


// MARK :- Helper extension to make keyboard disappear when user taps anywhere in the view outside of editor component
extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
