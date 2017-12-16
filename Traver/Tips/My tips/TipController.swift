//
//  TipController.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/20/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

protocol TipDelegate: class {
    func tipCreated(tip: Tip)
    func tipUpdated(tip: Tip)
}

class TipController: UITableViewController {
    
    @IBOutlet weak var pickerViewCountries: UIPickerView!
    @IBOutlet weak var textFieldTitle: UITextField!
    @IBOutlet weak var textViewText: UITextView!
    @IBOutlet weak var cellTipText: UITableViewCell!
    
    let textViewTextPlaceholder = "Why these regions are worth visiting. Recommended landmarks, hotels, restaurants and so".localized()
    
    let sectionsHeaders = ["Country".localized(), "Tip title".localized(), "Tip text".localized()];
    
    let countries = Codes.Country.allSorted
    
    var alertTitleLengthShown = false
    
    weak var tipDelegate: TipDelegate?
    
    var tip: Tip?
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    // MARK: - Lifeсycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldTitle.placeholder = textFieldTitle.placeholder?.localized()
        textViewText.text = textViewText.text.localized()
        
        textFieldTitle.delegate = self
        textViewText.delegate = self
        
        pickerViewCountries.dataSource = self
        pickerViewCountries.delegate = self
        
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap(recognizer:)))
        tapGestureRecognizer.isEnabled = false
        view.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.delegate = self
        
        setUpViews()
    }
    
    func setUpViews() {
        if let tip = tip {
            if let row = countries.index(of: tip.country) {
                pickerViewCountries.selectRow(row, inComponent: 0, animated: false)
            }
            textFieldTitle.text = tip.title
            textViewText.text = tip.text
            textViewText.textColor = .black
            pickerViewCountries.isUserInteractionEnabled = false
            self.title = "Edit tip".localized()
        } else {
            pickerViewCountries.selectRow(2, inComponent: 0, animated: false)
            self.title = "New tip".localized()
        }
    }
    
    // MARK: - Actions
    @IBAction func buttonSaveTapped(_ sender: Any) {
        if let title = textFieldTitle.text {
            if !title.isEmpty {
                if !textViewText.text.isEmpty && textViewText.text != textViewTextPlaceholder {
                    if let tip = tip {
                        let text = textViewText.text!
                        TipApiManager.shared.updateTip(id: tip.id, title: title, text: text) { updateDate in
                            tip.title = title
                            tip.text = text
                            tip.updateDate = updateDate
                            self.tipDelegate?.tipUpdated(tip: tip)
                        }
                    } else {
                        let selectedCountry = countries[pickerViewCountries.selectedRow(inComponent: 0)]
                        TipApiManager.shared.createTip(country: selectedCountry,
                                                       title: title, text: textViewText.text) { tip in
                            self.tipDelegate?.tipCreated(tip: tip) //(country: selectedCountry)
                        }
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
    
    let tipCountryRowHeight: CGFloat = 120
    let tipTitleRowHeight: CGFloat = 44
    let sectionHeaderHeight: CGFloat = 64
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
            case 0: return tipCountryRowHeight
            case 1: return tipTitleRowHeight
            case 2: return self.view.bounds.height - tipCountryRowHeight - tipTitleRowHeight - 3 * sectionHeaderHeight
            default: return 0
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension TipController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textFieldTitle.text {
            if text.count + string.count <= 100 {
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tapGestureRecognizer.isEnabled = true
    }
}

// MARK: - UITextViewDelegate
extension TipController: UITextViewDelegate {
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        tapGestureRecognizer.isEnabled = true
    }
}

// MARK: - UIPickerViewDataSource
extension TipController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
}

// MARK: - UIPickerViewDelegate
extension TipController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.text = countries[row].name
        pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 14)
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
}

// MARK: - UIGestureRecognizerDelegate
extension TipController: UIGestureRecognizerDelegate {
    @objc func handleTap(recognizer: UIGestureRecognizer) {
        if recognizer.state == .ended {
            textFieldTitle.resignFirstResponder()
            textViewText.resignFirstResponder()
            tapGestureRecognizer.isEnabled = false
        }
    }
}
