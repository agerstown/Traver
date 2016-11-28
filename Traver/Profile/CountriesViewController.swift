//
//  CountriesController.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/23/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class CountriesViewController: UIViewController {
    
    @IBOutlet weak var tableViewCountries: UITableView!
    var selectedCountriesCodes = [String]()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        self.title = "Countries".localized()
        
        self.tableViewCountries.dataSource = self
        self.tableViewCountries.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func buttonDoneClicked(_ button: UIBarButtonItem) {
        User.sharedInstance.visitedCountriesCodes = selectedCountriesCodes
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - tabelViewDataSource
extension CountriesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Region.regions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Region.regions[section].countriesCodes.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Region.regions[section].name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewCountries.dequeueReusableCell(withIdentifier: "CountryItemCell") as! CountryItemCell
        let regionCountriesCodes = Region.regions[indexPath.section].countriesCodes
        cell.labelCountryName.text = Countries.codesAndCountries[regionCountriesCodes[indexPath.row]]?.localized()
        cell.countryCode = regionCountriesCodes[indexPath.row]
        
        let image = self.selectedCountriesCodes.contains(regionCountriesCodes[indexPath.row]) ? UIImage(named: "item_checked") : UIImage(named: "item_unchecked")
        cell.buttonItemState.setImage(image, for: .normal)
        cell.selectionStyle = .none
        
        return cell
    }
    
}

// MARK: - tabelViewDelegate
extension CountriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableViewCountries.dequeueReusableCell(withIdentifier: "RegionHeaderCell") as! RegionHeaderCell
        header.labelRegionName.text = Region.regions[section].name
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CountryItemCell {
            guard let countryCode = cell.countryCode
                else { return }
            var image: UIImage?
            if !self.selectedCountriesCodes.contains(countryCode) {
                image = UIImage(named: "item_checked")
                self.selectedCountriesCodes.append(countryCode)
            } else {
                image = UIImage(named: "item_unchecked")
                self.selectedCountriesCodes.removeObject(countryCode)
            }
            cell.buttonItemState.setImage(image, for: .normal)
        }
    }
}
