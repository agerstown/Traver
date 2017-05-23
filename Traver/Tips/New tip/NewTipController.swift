//
//  NewTipController.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/20/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

protocol TipDelegate {
    func tipCreated(country: Codes.Country)
}

class NewTipController: UITableViewController {
    
    @IBOutlet weak var pickerViewCountries: UIPickerView!
    @IBOutlet weak var textFieldTitle: UITextField!
    @IBOutlet weak var textViewText: UITextView!
    
    let textViewTextPlaceholder = "Why these regions are worth visiting. Recommended landmarks, hotels, restaurants and so".localized()
    
    let sectionsHeaders = ["Country".localized(), "Tip title".localized(), "Tip text".localized()];
    
    let countries = Codes.Country.allSorted
    
    var alertTitleLengthShown = false
    
    var tipDelegate: TipDelegate?
    
    // MARK: - Lifeсycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "New tip".localized()
        
        textFieldTitle.placeholder = textFieldTitle.placeholder?.localized()
        textViewText.text = textViewText.text.localized()
        
        textFieldTitle.delegate = self
        textViewText.delegate = self
        
        pickerViewCountries.dataSource = self
        pickerViewCountries.delegate = self
        
        pickerViewCountries.selectRow(2, inComponent: 0, animated: false)
    }
    
    // MARK: - Actions
    @IBAction func buttonSaveTapped(_ sender: Any) {
        if let title = textFieldTitle.text {
            if !title.isEmpty {
                if !textViewText.text.isEmpty && textViewText.text != textViewTextPlaceholder {
                    let selectedCountry = countries[pickerViewCountries.selectedRow(inComponent: 0)]
                    TipApiManager.shared.createTip(countryCode: selectedCountry.code, title: title, text: textViewText.text) {
                        self.tipDelegate?.tipCreated(country: selectedCountry)
                    }
                    self.dismiss(animated: true, completion: nil)
                } else {
                    StatusBarManager.shared.showCustomStatusBarError(text: "Please enter tip text".localized())
                    textViewText.becomeFirstResponder()
                }
            } else {
                StatusBarManager.shared.showCustomStatusBarError(text: "Please enter tip title".localized())
                textFieldTitle.becomeFirstResponder()
            }
        } else {
            StatusBarManager.shared.showCustomStatusBarError(text: "Please enter tip title".localized())
            textFieldTitle.becomeFirstResponder()
        }
    }
    
    @IBAction func buttonCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsHeaders[section].localized()
    }
    
}

// MARK: - UITextFieldDelegate
extension NewTipController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textFieldTitle.text {
            if text.characters.count + string.characters.count <= 100 {
                return true
            } else {
                if !alertTitleLengthShown {
                    alertTitleLengthShown = true
                    StatusBarManager.shared.showCustomStatusBarError(text: "No more than 100 characters!".localized())
                }
                return false
            }
        }
        return true
    }
}

// MARK: - UITextViewDelegate
extension NewTipController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textViewText.text == textViewTextPlaceholder {
            textViewText.text = ""
            textViewText.textColor = .black
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textViewText.text.isEmpty {
            textViewText.text = textViewTextPlaceholder
            textViewText.textColor = .placeholderColor
        }
    }
}

// MARK: - UIPickerViewDataSource
extension NewTipController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
}

// MARK: - UIPickerViewDelegate
extension NewTipController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.text = countries[row].name
        pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 14)
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
}
