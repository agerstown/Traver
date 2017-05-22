//
//  TipsController.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/20/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

class TipsController: UIViewController {
    
    @IBOutlet weak var segmentedControlTipsCategory: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var barButtonAddTip: UIBarButtonItem!
    @IBOutlet weak var tableViewRegions: UITableView!
    
    var regions: [Codes.Region: Int] = [.REU: 0, .RAS: 0, .RNA: 0, .RSA: 0, .RAU: 0, .RAF: 0]
    var regionsArray: [Codes.Region] = []
    
    var countryCodes: [String: Int] = [:]
    
    var selectedRegion: Codes.Region?
    var countriesInSelectedRegion: [Codes.Country] = []
    
    let pictures: [Codes.Region: UIImage?] = [.REU: UIImage(named: "europe"), .RAS: UIImage(named: "asia"),
                                             .RNA: UIImage(named: "north-america"), .RSA: UIImage(named: "south-america"),
                                             .RAU: UIImage(named: "australia"), .RAF: UIImage(named: "africa")]
    
    let activityIndicatorInitialLoading = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewRegions.dataSource = self
        tableViewRegions.delegate = self
        
        startSpinning()
        reloadRegionsTable() {
            self.stopSpinning()
        }
        
    }
    
    // MARK: Regions update
    func reloadRegionsTable(completion: @escaping () -> Void) {
        TipApiManager.shared.getExistingTipsCountries() { countryCodes in
            self.countryCodes = countryCodes
            for code in countryCodes {
                if let region = Codes.countryToRegion[code.key] {
                    self.regions[region]! += code.value
                }
            }
            completion()
            
            for region in self.regions {
                if region.value == 0 {
                    self.regions.removeValue(forKey: region.key)
                }
            }
            
            self.regionsArray = Array(self.regions.keys).sorted(by: { $0.rawValue < $1.rawValue })
            self.tableViewRegions.reloadData()
        }
    }
    
    // MARK: - Spinner for initial regions loading
    func startSpinning() {
        tableViewRegions.isHidden = true
        
        activityIndicatorInitialLoading.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
        self.view.addSubview(activityIndicatorInitialLoading)
        activityIndicatorInitialLoading.startAnimating()
    }
    
    func stopSpinning() {
        activityIndicatorInitialLoading.stopAnimating()
        activityIndicatorInitialLoading.removeFromSuperview()
        tableViewRegions.isHidden = false
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? TipsCountriesInRegionController {
            controller.countryCodes = countryCodes
            controller.countries = countriesInSelectedRegion
            controller.title = selectedRegion?.name
        }
    }
    
}

// MARK: - UITableViewDataSource
extension TipsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewRegions.dequeue(TipsRegionCell.self)
        if indexPath.row % 2 == 1 {
            cell.backgroundColor = .yellowTraverColor
        }
        
        let region = regionsArray[indexPath.row]
        
        cell.labelRegionName.text = region.name
        if let picture = pictures[region] {
            cell.imageViewRegionPicture.image = picture
        }
        
        if let tipsNumber = regions[region] {
            cell.labelNumberOfTips.text = "%d tips".localized(for: tipsNumber)
        }
        
        return cell
    }

}

// MARK: - UITableViewDelegate
extension TipsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.view.bounds.height - 44 - searchBar.bounds.height) / CGFloat(regions.count)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewRegions.deselectRow(at: indexPath, animated: true)
        selectedRegion = regionsArray[indexPath.row]
        
        var countries: [Codes.Country] = []
        for country in Codes.regions[selectedRegion!.rawValue].1 {
            if countryCodes.keys.contains(country.code) {
                countries.append(country)
            }
        }
        countriesInSelectedRegion = countries
        
        performSegue(withIdentifier: "segueToTipsCountriesInRegion", sender: nil)
    }
}
