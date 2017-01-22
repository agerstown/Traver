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
    
    //var regions = Region.regions
    //var selectedCountriesCodes = [String]()
    var regions = Codes.regions
    var selectedCountries: [Codes.Country] = []
    //var selectedRegions = [Region]()
    
//    var selectedCountries: [Country] {
//        var countries = [Country]()
//        for region in selectedRegions {
//            countries.append(contentsOf: region.visitedCountries)
//        }
//        return countries
//    }
    
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
        //User.sharedInstance.visitedCountriesCodes = selectedCountriesCodes
        //User.sharedInstance.visitedCountries = selectedCountries
        //User.sharedInstance.visitedRegions = selectedRegions
        saveVisitedCountries()
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveVisitedCountries() {
        for country in selectedCountries {
            User.sharedInstance.saveCountryVisit(code: country.code)
            //saveCountry(with: country.code)
        }
    }
    
//    func saveCountry(with code: String) {
//        let region = findOrCreateRegion(for: code)
//        createCountryIfNeeded(for: code, in: region)
//    }
//    
//    func createCountryIfNeeded(for code: String, in region: Region) {
//        if !User.sharedInstance.visitedCountries.contains(where: { $0.code == code }) {
//            let country = Country(code: code, region: region)
//            region.visitedCountries.append(country)
//        }
//    }
//    
//    func findOrCreateRegion(for countryCode: String) -> Region {
//        let region: Region?
//        let regionCode = Codes.countryToRegion[countryCode]!
//        if User.sharedInstance.visitedRegions.contains(where: { $0.code == regionCode }) {
//            let visitedRegions = User.sharedInstance.visitedRegions
//            region = visitedRegions.filter { $0.code == regionCode }.first
//        } else {
//            region = Region(code: regionCode)
//            User.sharedInstance.visitedRegions.append(region!)
//        }
//        return region!
//    }
}

// MARK: - UITableViewDataSource
extension CountriesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //return regions.count
        return Codes.regions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return regions[section].countriesCodes.count
        let region = Codes.Region(rawValue: section)!
        let countriesInRegion = regions[region]!
        return countriesInRegion.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //return regions[section].name
        let region = Codes.Region(rawValue: section)!
        return region.name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewCountries.dequeueReusableCell(withIdentifier: "CountryItemCell") as! CountryItemCell
        //let regionCountriesCodes = regions[indexPath.section].countriesCodes
        //cell.labelCountryName.text = Countries.codesAndNames[regionCountriesCodes[indexPath.row]]?.localized()
        //cell.countryCode = regionCountriesCodes[indexPath.row]
        
        let region = Codes.Region(rawValue: indexPath.section)!
        let countriesInRegion = Codes.regions[region]!
        cell.labelCountryName.text = countriesInRegion[indexPath.row].name
        cell.country = countriesInRegion[indexPath.row]
        
        //let image = self.selectedCountriesCodes.contains(regionCountriesCodes[indexPath.row]) ? UIImage(named: "item_checked") : UIImage(named: "item_unchecked")
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
            //guard let countryCode = cell.countryCode
            //    else { return }
            guard let country = cell.country else { return }
            var image: UIImage?
//            if !self.selectedCountriesCodes.contains(countryCode) {
//                image = UIImage(named: "item_checked")
//                self.selectedCountriesCodes.append(countryCode) { Countries.codesAndNames[$0]!.localized() < Countries.codesAndNames[$1]!.localized() }
//            } else {
//                image = UIImage(named: "item_unchecked")
//                self.selectedCountriesCodes.removeObject(countryCode)
//            }
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
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBar.setShowsCancelButton(true, animated: true)
//    }
//    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.text = ""
//        searchBar.resignFirstResponder()
//        searchBar.setShowsCancelButton(false, animated: true)
//        //regions = Region.regions
//        regions = Codes.regions
//        tableViewCountries.reloadData()
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        //regions = filterRegionsAndCountries(with: searchText)
//        tableViewCountries.reloadData()
//    }
//    
//    func filterRegionsAndCountries(with filter: String) -> [Region] {
//        if filter.isEmpty {
//            return Region.regions
//        }
//        
//        let filteredCountriesCodes = Countries.codes.filter { Countries.codesAndNames[$0]!.range(of: filter) != nil }
//        
//        var filteredRegions = [Region]()
//        for region in Region.regions {
//            let filteredCountriesForRegion = region.countriesCodes.filter { filteredCountriesCodes.contains($0) }
//            if filteredCountriesForRegion.count != 0 {
//                let filteredRegion = Region(type: region.type, name: region.name)
//                filteredRegion.countriesCodes = filteredCountriesForRegion
//                filteredRegions.append(filteredRegion)
//            }
//        }
//        return filteredRegions
//    }
}
