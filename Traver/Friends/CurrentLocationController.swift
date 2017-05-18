//
//  CurrentLocationController.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/18/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

protocol CurrentLocationDelegate {
    func locationSaved()
}

class CurrentLocationController: UIViewController {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var pickerViewCountry: UIPickerView!
    @IBOutlet weak var textFieldRegion: UITextField!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonHide: UIButton!
    
    var backgroundImage: UIImage?
    
    let countries = Codes.Country.allSorted
    
    var currentLocationDelegate: CurrentLocationDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let backgroundImage = backgroundImage {
            view.backgroundColor = UIColor(patternImage: backgroundImage)
        }
        
        labelTitle.adjustsFontSizeToFitWidth = true
        
        labelTitle.text = "Choose your current location.".localized()
        textFieldRegion.placeholder = "City, region, place..".localized()
        
        buttonSave.setTitle("Save".localized(), for: .normal)
        buttonSave.layer.cornerRadius = 5
        
        buttonHide.setTitle("Hide".localized(), for: .normal)
        buttonHide.layer.cornerRadius = 5
        
        pickerViewCountry.dataSource = self
        pickerViewCountry.delegate = self
        
        var rowIndex = 2
        if let country = User.shared.currentCountryCode {
            if let countryCode = Codes.Country.all.filter ({ $0.code == country }).first {
                if let index = countries.index(of: countryCode) {
                    rowIndex = index
                }
            }
        }
        pickerViewCountry.selectRow(rowIndex, inComponent: 0, animated: false)
        
        if let region = User.shared.currentRegion {
            textFieldRegion.text = region
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func buttonSaveTapped(_ sender: Any) {
        let selectedCountry = countries[pickerViewCountry.selectedRow(inComponent: 0)]
        
        var region: String?
        if let text = textFieldRegion.text {
            region = text.isEmpty ? nil : text
        }
        UserApiManager.shared.setCurrentLocation(countryCode: selectedCountry.code, region: region) { success in
            if success {
                self.currentLocationDelegate?.locationSaved()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func buttonHideTapped(_ sender: Any) {
        UserApiManager.shared.setCurrentLocation(countryCode: nil, region: nil) { success in
            if success {
                self.currentLocationDelegate?.locationSaved()
                self.dismiss(animated: true, completion: nil)
            }
        }

    }
}

// MARK: - UIGestureRecognizerDelegate
extension CurrentLocationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view {
            return !(view.restorationIdentifier == "viewCurrentLocation" || view.isKind(of: UITableView.self) || view.isKind(of: UIButton.self))
        }
        return true
        
    }
    
    func handleTap(recognizer: UIGestureRecognizer) {
        if recognizer.state == .ended {
            if textFieldRegion.isFirstResponder {
                textFieldRegion.resignFirstResponder()
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: - UIPickerViewDataSource
extension CurrentLocationController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
}

// MARK: - UIPickerViewDelegate
extension CurrentLocationController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.text = countries[row].name
        pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 14)
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }

}
