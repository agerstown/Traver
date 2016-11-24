//
//  CountriesController.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/23/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class CountriesViewController: UITableViewController {
    
    @IBOutlet var tableViewCountries: UITableView!
    var selectedCountriesCodes = [String]()
    
    // MARK: - Actions
    @IBAction func buttonDoneClicked(_ button: UIBarButtonItem) {
        User.sharedInstance.visitedCountriesCodes = selectedCountriesCodes
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonCountryItemStateClicked(_ button: UIButton) {
        if let cell = button.superview?.superview as? CountryItemCell {
            guard let countryCode = Countries.countriesAndCodes[cell.labelCountryName.text!]
                else { return }
            var image: UIImage?
            if !self.selectedCountriesCodes.contains(countryCode) {
                image = UIImage(named: "item_checked")
                self.selectedCountriesCodes.append(countryCode)
            } else {
                image = UIImage(named: "item_unchecked")
                self.selectedCountriesCodes.removeObject(countryCode)
            }
            button.setImage(image, for: .normal)
        }
    }
    
    // MARK: - tabelViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Regions.regions.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Regions.regions[section].countriesCodes.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Regions.regions[section].regionName
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableViewCountries.dequeueReusableCell(withIdentifier: "CountryItemCell") as! CountryItemCell
        let regionCountriesCodes = Regions.regions[indexPath.section].countriesCodes
        cell.labelCountryName.text = Countries.codesAndCountries[regionCountriesCodes[indexPath.row]]
        
        let image = self.selectedCountriesCodes.contains(cell.labelCountryName.text!) ? UIImage(named: "item_checked") : UIImage(named: "item_unchecked")
        cell.buttonItemState.setImage(image, for: .normal)
        cell.selectionStyle = .none
        
        return cell
    }
    
}
