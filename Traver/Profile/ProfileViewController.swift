//
//  ProfileViewController.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/21/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation
import Photos

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableViewVisitedCountries: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var viewUserInfo: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelJob: UILabel!
    @IBOutlet weak var labelVisitedCountries: UILabel!
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var buttonEditUserInfo: UIButton!
    
    var mapImage: SVGKImage = SVGKImage(named: "WorldMap.svg")!
    
    let visitedCountriesText = "%d/176 countries visited"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Profile".localized()
        buttonEditUserInfo.setTitle(" Edit".localized(), for: .normal)
        
        let nib = UINib(nibName: "VisitedRegionHeaderView", bundle: nil)
        tableViewVisitedCountries.register(nib, forHeaderFooterViewReuseIdentifier: "VisitedRegionHeaderView")
        
        tableViewVisitedCountries.dataSource = self
        tableViewVisitedCountries.delegate = self
        scrollView.delegate = self
        
        imageViewPhoto.layer.cornerRadius = imageViewPhoto.frame.height / 2
        
        // setting up the map's size
        let width = viewMap.frame.size.width
        let scale = width / mapImage.size.width
        let height = mapImage.size.height * scale
        mapImage.size = CGSize(width: width, height: height)
        let SVGLayeredImageView = SVGKLayeredImageView(svgkImage: mapImage)
        if let imageView = SVGLayeredImageView {
            viewMap.addSubview(imageView)
        }
        
        colorVisitedCounties(on: mapImage)
        
        NotificationCenter.default.addObserver(self, selector: #selector(countryCodeImported(notification:)), name: VisitedCountriesImporter.CountryCodeImportedNotification, object: nil)
    
        //if !UserDefaults.standard.bool(forKey: VisitedCountriesImporter.isAlreadyImported) { // сделать onboarding
//            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
//                if status == .authorized {
//                    VisitedCountriesImporter.sharedInstance.fetchVisitedCountriesCodesFromPhotos()
//                }
//            })
        //}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        colorVisitedCounties(on: mapImage)
        tableViewVisitedCountries.reloadData()
        labelVisitedCountries.text = visitedCountriesText.localized(for: User.sharedInstance.visitedCountriesCodes.count)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController {
            if let controller = navController.viewControllers[0] as? CountriesViewController {
                controller.selectedCountriesCodes = User.sharedInstance.visitedCountriesCodes
            }
        }
    }

    // MARK: - Notifications
    func countryCodeImported(notification: NSNotification) {
        if let countryCode = notification.userInfo?[VisitedCountriesImporter.CountryCodeInfoKey] as? String {
            if !User.sharedInstance.visitedCountriesCodes.contains(countryCode) {
                
                let region = Region.regions.filter { $0.countriesCodes.contains(countryCode) }[0]
                
                let existingSection = User.sharedInstance.visitedRegions.contains(region)
                
                User.sharedInstance.visitedCountriesCodes.append(countryCode, using: { Countries.codesAndNames[$0]!.localized() < Countries.codesAndNames[$1]!.localized() } )
                
                let countriesLayers = mapImage.caLayerTree.sublayers?[0].sublayers as! [CAShapeLayer]
                if let newCountryLayer = countriesLayers.first(where: { $0.name! == countryCode } ) {
                    newCountryLayer.fillColor = UIColor.blue.cgColor
                }
                
                let visitedRegions = User.sharedInstance.visitedRegions
                let visitedCountriesInRegion = User.sharedInstance.visitedCountriesCodes(in: region)
                
                if existingSection {
                    tableViewVisitedCountries.insertRows(at: [IndexPath(row: visitedCountriesInRegion.index(of: countryCode)!, section: visitedRegions.index(of: region)!)], with: .automatic)
                } else {
                    tableViewVisitedCountries.insertSections(IndexSet(integer: visitedRegions.index(of: region)!), with: .automatic)
                }
                
                labelVisitedCountries.text = visitedCountriesText.localized(for: User.sharedInstance.visitedCountriesCodes.count)
            }
        }
    }
    
    // MARK: - Work with the map
    func colorVisitedCounties(on map: SVGKImage) {
        let countriesLayers = map.caLayerTree.sublayers?[0].sublayers as! [CAShapeLayer]
        let visitedCountriesLayers = countriesLayers.filter { User.sharedInstance.visitedCountriesCodes.contains($0.name!) }
        
        for layer in visitedCountriesLayers {
            let color = UIColor.blue
            layer.fillColor = color.cgColor
        }
    }
}

// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return User.sharedInstance.visitedRegions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let visitedCountriesInSection = User.sharedInstance.visitedCountriesCodes.filter { User.sharedInstance.visitedRegions[section].countriesCodes.contains($0) }
        return visitedCountriesInSection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewVisitedCountries.dequeueReusableCell(withIdentifier: "VisitedCountryItemCell") as! VisitedCountryItemCell
        
        let visitedCountriesInSection = User.sharedInstance.visitedCountriesCodes.filter { User.sharedInstance.visitedRegions[indexPath.section].countriesCodes.contains($0) }
        cell.labelCountryName.text = Countries.codesAndNames[visitedCountriesInSection[indexPath.row]]?.localized()
        cell.countryCode = visitedCountriesInSection[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let cell = tableViewVisitedCountries.cellForRow(at: indexPath) as! VisitedCountryItemCell
            let countryCode = cell.countryCode!
            
            User.sharedInstance.visitedCountriesCodes.removeObject(countryCode)
            
            let countriesLayers = mapImage.caLayerTree.sublayers?[0].sublayers as! [CAShapeLayer]
            if let deletedCountryLayer = countriesLayers.first(where: { $0.name! == countryCode } ) {
                deletedCountryLayer.fillColor = UIColor.countryDefaultColor.cgColor
            }
            
            if tableViewVisitedCountries.numberOfRows(inSection: indexPath.section) == 1 {
                tableViewVisitedCountries.deleteSections([indexPath.section], with: .automatic)
            } else {
                tableViewVisitedCountries.deleteRows(at: [indexPath], with: .automatic)
            }
            
            if let header = tableViewVisitedCountries.headerView(forSection: indexPath.section) as? VisitedRegionHeaderView {
                configureVisitedCountriesNumber(for: header, in: indexPath.section)
            }
            
            labelVisitedCountries.text = visitedCountriesText.localized(for: User.sharedInstance.visitedCountriesCodes.count)
        }
    }
    
    func configureVisitedCountriesNumber(for header: VisitedRegionHeaderView, in section: Int) {
        header.labelVisitedCountriesNumber.text = "\(tableViewVisitedCountries.numberOfRows(inSection: section))/\(User.sharedInstance.visitedRegions[section].countriesCodes.count)"
    }

}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableViewVisitedCountries.dequeueReusableHeaderFooterView(withIdentifier: "VisitedRegionHeaderView") as! VisitedRegionHeaderView
        header.labelRegionName.text = User.sharedInstance.visitedRegions[section].name
        configureVisitedCountriesNumber(for: header, in: section)
        header.contentView.backgroundColor = UIColor.headerColor
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }
}

// MARK: - UIScrollViewDelegate
extension ProfileViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return viewMap
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0)
    }
}

