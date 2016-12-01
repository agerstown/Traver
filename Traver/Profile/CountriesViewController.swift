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
    
    var regions = Region.regions
    var selectedCountriesCodes = [String]()
    
    var currentOperation: Operation?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        self.title = "Countries".localized()
        
        self.searchBar.delegate = self
        self.tableViewCountries.dataSource = self
        self.tableViewCountries.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func buttonDoneClicked(_ button: UIBarButtonItem) {
        User.sharedInstance.visitedCountriesCodes = selectedCountriesCodes
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension CountriesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return regions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regions[section].countriesCodes.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return regions[section].name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewCountries.dequeueReusableCell(withIdentifier: "CountryItemCell") as! CountryItemCell
        let regionCountriesCodes = regions[indexPath.section].countriesCodes
        cell.labelCountryName.text = Countries.codesAndNames[regionCountriesCodes[indexPath.row]]?.localized()
        cell.countryCode = regionCountriesCodes[indexPath.row]
        
        let image = self.selectedCountriesCodes.contains(regionCountriesCodes[indexPath.row]) ? UIImage(named: "item_checked") : UIImage(named: "item_unchecked")
        cell.buttonItemState.setImage(image, for: .normal)
        cell.selectionStyle = .none
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension CountriesViewController: UITableViewDelegate {
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

// MARK: - UISearchBarDelegate
extension CountriesViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        regions = Region.regions
        tableViewCountries.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //filterRegionsAndCountriesInBackground(with: searchText)
        regions = filterRegionsAndCountries(with: searchText)
        tableViewCountries.reloadData()
    }
    
//    func filterRegionsAndCountriesInBackground(with filter: String) {
//        currentOperation?.cancel()
//        currentOperation = BlockOperation { [weak self] in
//            let regions = self?.filterRegionsAndCountries(with: filter)
//            DispatchQueue.main.async {
//                if let regions = regions {
//                    self?.regions = regions
//                    self?.tableViewCountries.reloadData()
//                    self?.currentOperation = nil
//                }
//            }
//        }
//        currentOperation?.start()
//    }
    
    func filterRegionsAndCountries(with filter: String) -> [Region] {
        if filter.isEmpty {
            return Region.regions
        }
        
        let filteredCountriesCodes = Countries.codes.filter { Countries.codesAndNames[$0]!.range(of: filter) != nil }
        
        var filteredRegions = [Region]()
        for region in Region.regions {
            let filteredCountriesForRegion = region.countriesCodes.filter { filteredCountriesCodes.contains($0) }
            if filteredCountriesForRegion.count != 0 {
                let filteredRegion = Region(type: region.type, name: region.name)
                filteredRegion.countriesCodes = filteredCountriesForRegion
                filteredRegions.append(filteredRegion)
            }
        }
        return filteredRegions
    }
}
