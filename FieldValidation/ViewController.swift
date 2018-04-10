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
    
    @IBAction func textFieldEdited(_ sender: UITextField) {
        doValidation()
    }
    
    @IBAction func moveTapped(_ sender: Any) {
        let location = CLLocationCoordinate2DMake(Double(latitudeField.text!)!,
                                                  Double(longitudeField.text!)!)
        let region = MKCoordinateRegionMake(location, MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0))
        mapView.setRegion(region, animated: true)
    }
    
    let latitudeValidator = ViewController.validator(90)
    let longitudeValidator = ViewController.validator(180)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        moveButton.isEnabled = false
        
        latitudeField.delegate = self
        longitudeField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private static func validator(_ absoluteValue: Double) -> (String?) -> Bool {
        func valid(_ string: String?) -> Bool {
            guard let string = string, // Mask optional by using same name
                  let asDouble = Double(string) else { // In this scope we have unwrapped string instead of optinal
                return false
            }
            return abs(asDouble) <= absoluteValue
        }
        return valid
    }
}

extension ViewController: UITextFieldDelegate {
    
    private func doValidation() {
        moveButton.isEnabled = latitudeValidator(latitudeField.text) && longitudeValidator(longitudeField.text)
    }
    
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
        return true
    }
    
}
