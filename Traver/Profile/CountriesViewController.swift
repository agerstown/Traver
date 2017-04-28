//
//  CountriesController.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/23/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class CountriesViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableViewCountries: UITableView!
    
    var regions = Codes.regions
    var selectedCountries: [Codes.Country] = []
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.title = "Countries".localized()
        
        self.searchBar.delegate = self
        self.tableViewCountries.dataSource = self
        self.tableViewCountries.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func buttonDoneClicked(_ button: UIBarButtonItem) {
        UserApiManager.shared.updateCountryVisits(user: User.shared, codes: selectedCountries.map { $0.code }) {
            NotificationCenter.default.post(name: UserApiManager.shared.CountriesUpdatedNotification, object: nil)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension CountriesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return regions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let countriesInRegion = regions[section].1
        return countriesInRegion.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let region = regions[section].0
        return region.name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewCountries.dequeueReusableCell(withIdentifier: "CountryItemCell") as! CountryItemCell
        
        let countriesInRegion = regions[indexPath.section].1
        cell.labelCountryName.text = countriesInRegion[indexPath.row].name
        cell.country = countriesInRegion[indexPath.row]
        
        let image = selectedCountries.contains(countriesInRegion[indexPath.row]) ? UIImage(named: "item_checked") : UIImage(named: "item_unchecked")
        cell.buttonItemState.setImage(image, for: .normal)
        cell.selectionStyle = .none
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension CountriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CountryItemCell {
            
            guard let country = cell.country else { return }
            
            var image: UIImage?
            if !selectedCountries.contains(country) {
                image = UIImage(named: "item_checked")
                selectedCountries.append(country) { $0.name < $1.name }
            } else {
                image = UIImage(named: "item_unchecked")
                selectedCountries.removeObject(country)
            }
            
            cell.buttonItemState.setImage(image, for: .normal)
        }
    }
}

// MARK: - UISearchBarDelegate
extension CountriesViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        regions = Codes.regions
        tableViewCountries.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        regions = filterRegionsAndCountries(with: searchText)
        tableViewCountries.reloadData()
    }
    
    func filterRegionsAndCountries(with filter: String) -> [(Codes.Region, [Codes.Country])] {
        if filter.isEmpty {
            return Codes.regions
        }
        
        let filteredCountriesCodes = Codes.Country.all.filter { $0.name.range(of: filter) != nil }
        
        var filteredRegions: [(Codes.Region, [Codes.Country])] = []
        for region in Codes.regions {
            let filteredCountriesForRegion = region.1.filter { filteredCountriesCodes.contains($0) }
            if filteredCountriesForRegion.count != 0 {
                filteredRegions.append((region.0, filteredCountriesForRegion))
            }
        }
        
        return filteredRegions
    }
}
