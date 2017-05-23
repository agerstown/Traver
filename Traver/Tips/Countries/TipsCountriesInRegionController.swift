//
//  TipsCountriesInRegionController.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/20/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

class TipsCountriesInRegionController: UIViewController {
    
    @IBOutlet weak var tableViewTipsCountries: UITableView!
    
    var countryCodes: [String: Int] = [:]
    var countries: [Codes.Country] = []
    
    var selectedCountry: Codes.Country?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewTipsCountries.dataSource = self
        tableViewTipsCountries.delegate = self
        
        tableViewTipsCountries.tableFooterView = UIView()
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? TipsInCountryController {
            controller.country = selectedCountry
        }
    }
    
}

// MARK: - UITableViewDataSource
extension TipsCountriesInRegionController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewTipsCountries.dequeue(TipsCountryCell.self)
        let country = countries[indexPath.row]
        cell.labelCountryName.text = country.name
        
        if let tipsNumber = countryCodes[country.code] {
            cell.labelTipsNumber.text = "%d tips".localized(for: tipsNumber)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TipsCountriesInRegionController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewTipsCountries.deselectRow(at: indexPath, animated: true)
        selectedCountry = countries[indexPath.row]
        performSegue(withIdentifier: "segueToTipsList", sender: nil)
    }
}
