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
    @IBOutlet weak var tableViewRegions: UITableView!
    @IBOutlet weak var viewNoFriends: UIView!
    
    var regions: [Codes.Region: Int] = [.REU: 0, .RAS: 0, .RNA: 0, .RSA: 0, .RAU: 0, .RAF: 0]
    var regionsArray: [Codes.Region] = []
    var countryCodes: [String: Int] = [:]
    
    var allRegions: [Codes.Region: Int] = [.REU: 0, .RAS: 0, .RNA: 0, .RSA: 0, .RAU: 0, .RAF: 0]
    var allRegionsArray: [Codes.Region] = []
    var allCountryCodes: [String: Int] = [:]
    
    var friendsRegions: [Codes.Region: Int] = [.REU: 0, .RAS: 0, .RNA: 0, .RSA: 0, .RAU: 0, .RAF: 0]
    var friendsRegionsArray: [Codes.Region] = []
    var friendsCountryCodes: [String: Int] = [:]
    
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
        
        segmentedControlTipsCategory.setTitle("All".localized(), forSegmentAt: 0)
        segmentedControlTipsCategory.setTitle("Friends".localized(), forSegmentAt: 1)
        
        reloadRegionsTable()
    }
    
    // MARK: Regions update
    func reloadRegionsTable() {
        if segmentedControlTipsCategory.selectedSegmentIndex == 0 {
            viewNoFriends.isHidden = true
            tableViewRegions.isHidden = false
            if allRegionsArray.isEmpty {
                startSpinning()
                TipApiManager.shared.getExistingTipsCountries() { countryCodes in
                    self.filterCountryCodes(codes: countryCodes, countryCodes: &self.allCountryCodes,
                                            regions: &self.allRegions, regionsArray: &self.allRegionsArray) {
                        self.stopSpinning()
                    }
                }
            } else {
                countryCodes = allCountryCodes
                regions = allRegions
                regionsArray = allRegionsArray
                tableViewRegions.reloadData()
            }
        } else {
            if friendsRegionsArray.isEmpty {
                startSpinning()
                TipApiManager.shared.getExistingTipsCountriesFriends() { countryCodes in
                    self.filterCountryCodes(codes: countryCodes, countryCodes: &self.friendsCountryCodes,
                                            regions: &self.friendsRegions, regionsArray: &self.friendsRegionsArray) {
                        self.stopSpinning()
                        self.configureFriendsSection()
                    }
                }
            } else {
                countryCodes = friendsCountryCodes
                regions = friendsRegions
                regionsArray = friendsRegionsArray
                tableViewRegions.reloadData()
            }
        }
    }
    
    func configureFriendsSection() {
        if countryCodes.count == 0 {
            viewNoFriends.isHidden = false
            tableViewRegions.isHidden = true
        } else {
            viewNoFriends.isHidden = true
            tableViewRegions.isHidden = false
        }
    }
    
    func filterCountryCodes(codes: [String: Int], countryCodes: inout [String: Int], regions: inout [Codes.Region: Int],
             regionsArray: inout [Codes.Region], completion: (() -> Void)?) {
        countryCodes = codes
        var regionsDict: [Codes.Region: Int] = [.REU: 0, .RAS: 0, .RNA: 0, .RSA: 0, .RAU: 0, .RAF: 0]
        for code in codes {
            if let region = Codes.countryToRegion[code.key] {
                regionsDict[region]! += code.value
            }
            regions = regionsDict
        }
        
        for region in regionsDict {
            if region.value == 0 {
                regions.removeValue(forKey: region.key)
            }
        }
        regionsArray = Array(regions.keys).sorted(by: { $0.rawValue < $1.rawValue })
        
        self.countryCodes = countryCodes
        self.regions = regions
        self.regionsArray = regionsArray
        
        if let completion = completion {
            completion()
        }
        
        self.tableViewRegions.reloadData()
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
    
    // MARK: - Actions
    @IBAction func segmentedControlTipsCategoryChanged(_ sender: UISegmentedControl) {
        reloadRegionsTable()
    }
    
    @IBAction func buttonMyTipsTapped(_ sender: Any) {
        if User.shared.token == nil {
            let alert = UIAlertController(title: "Log in".localized(), message: "Please log in using your iCloud account (in Settigs) or Facebook to leave tips".localized(), preferredStyle: UIAlertControllerStyle.alert)
            let connectFacebookAction = UIAlertAction(title: "Connect Facebook".localized(), style: .default) { _ in
                FacebookHelper.shared.login()
            }
            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel)
            alert.addAction(connectFacebookAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "segueToMyTipsController", sender: nil)
        }
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? TipsCountriesInRegionController {
            controller.countryCodes = countryCodes
            controller.countries = countriesInSelectedRegion
            controller.title = selectedRegion?.name
            controller.friends = countryCodes == friendsCountryCodes
        } else if let controller = segue.destination as? MyTipsController {
            controller.tipsDelegate = self
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
        } else {
            cell.backgroundColor = .white
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
        return tableViewRegions.frame.height / CGFloat(regions.count)
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

// MARK: - TipsDelegate
extension TipsController: TipsDelegate {
    func tipCreated(country: Codes.Country) {
        TipApiManager.shared.getExistingTipsCountries() { countryCodes in
            self.filterCountryCodes(codes: countryCodes, countryCodes: &self.allCountryCodes,
                                    regions: &self.allRegions, regionsArray: &self.allRegionsArray, completion: nil)
        }
    }
}
