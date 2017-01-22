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
    @IBOutlet weak var viewTableViewHeader: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var viewUserInfo: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelLocation: UILabel!
    @IBOutlet weak var labelVisitedCountries: UILabel!
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var buttonEditUserInfo: UIButton!
    @IBOutlet weak var buttonFillInfo: UIButton!
    
    @IBOutlet weak var constraintScrollViewHeight: NSLayoutConstraint!
    
    var mapImage: SVGKImage = SVGKImage(named: "WorldMap.svg")!
    
    let visitedCountriesText = "%d/176 countries visited"
    let mapHeightToWidthRatio: CGFloat = 1.5
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Profile".localized()
        buttonEditUserInfo.setTitle(" " + "Edit".localized(), for: .normal)
        
        let nib = UINib(nibName: "VisitedRegionHeaderView", bundle: nil)
        tableViewVisitedCountries.register(nib, forHeaderFooterViewReuseIdentifier: "VisitedRegionHeaderView")
        
        tableViewVisitedCountries.dataSource = self
        tableViewVisitedCountries.delegate = self
        scrollView.delegate = self
        
        labelName.adjustsFontSizeToFitWidth = true
        labelLocation.adjustsFontSizeToFitWidth = true
        labelVisitedCountries.adjustsFontSizeToFitWidth = true
        
        buttonFillInfo.layer.cornerRadius = 5
        buttonFillInfo.layer.borderWidth = 1
        buttonFillInfo.layer.borderColor = UIColor.black.cgColor
        
        imageViewPhoto.layer.cornerRadius = imageViewPhoto.frame.height / 2
        
        // setting up the scroll view and table view header sizes
        scrollView.frame.size.width = UIScreen.main.bounds.width
        constraintScrollViewHeight.constant = scrollView.frame.size.width / mapHeightToWidthRatio
        viewTableViewHeader.frame.size.height = constraintScrollViewHeight.constant + viewUserInfo.frame.size.height
        
        // setting up the map and it's size
        let width = scrollView.frame.size.width
        let scale = width / mapImage.size.width
        let height = mapImage.size.height * scale
        mapImage.size = CGSize(width: width, height: height)
        if let imageView = SVGKLayeredImageView(svgkImage: mapImage) {
            viewMap.addSubview(imageView)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(countryCodeImported(notification:)), name: VisitedCountriesImporter.CountryCodeImportedNotification, object: nil)
        
        //print(String())
        //let bla = String(describing: Codes.Country.AE)
        //print(bla)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateProfileInfo()
        
        mapImage.colorVisitedCounties()
        tableViewVisitedCountries.reloadData()
        labelVisitedCountries.text = visitedCountriesText.localized(for: User.sharedInstance.visitedCountries.count)
        //labelVisitedCountries.text = visitedCountriesText.localized(for: User.sharedInstance.visitedCountriesCodes.count)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    @IBAction func buttonShareTapped(_ sender: UIButton) {
        PhotosAccessManager.sharedInstance.shareToPhotoAlbum(controller: self)
    }

    @IBAction func buttonFillInfoTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Profile info".localized(), message: "How do you want to fill your info?".localized(), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Connect Facebook".localized(), style: .default) { _ in
            FacebookHelper.sharedInstance.login() {
                self.updateProfileInfo()
            }
        })
        alert.addAction(UIAlertAction(title: "Manually".localized(), style: .default) { _ in
            self.performSegue(withIdentifier: "segueToEditProfile", sender: nil)
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        self.present(alert, animated: true)
    }
    
    func updateProfileInfo() {
        buttonFillInfo.isHidden = User.sharedInstance.name != nil
        
        labelName.text = User.sharedInstance.name
        labelLocation.text = User.sharedInstance.location
        
        imageViewPhoto.image = User.sharedInstance.photo != nil ? User.sharedInstance.photo : UIImage(named: "default_photo")
    }
    
    @IBAction func buttonEditTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueToEditProfile", sender: nil)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController {
            if let controller = navController.viewControllers[0] as? CountriesViewController {
                //controller.selectedCountriesCodes = User.sharedInstance.visitedCountriesCodes
                //controller.selectedCountries = User.sharedInstance.visitedCountries
                controller.selectedCountries = Codes.Country.all.filter { (country) in
                    User.sharedInstance.visitedCountries.contains(where: { $0.code == country.code } )
                }
            }
        }
    }

    // MARK: - Notifications
    func countryCodeImported(notification: NSNotification) {
        if let countryCode = notification.userInfo?[VisitedCountriesImporter.CountryCodeInfoKey] as? String {
            if !User.sharedInstance.visitedCountries.contains(where: { $0.code == countryCode }) {
            //if !User.sharedInstance.visitedCountriesCodes.contains(countryCode) {
                
                let country = User.sharedInstance.saveCountryVisit(code: countryCode)!
                
                //let region = Region.regions.filter { $0.countriesCodes.contains(countryCode) }[0]
                let region = country.region
                
                let existingSection = User.sharedInstance.visitedRegions.contains(region)
                
                //User.sharedInstance.visitedCountriesCodes.append(countryCode) { Countries.codesAndNames[$0]!.localized() < Countries.codesAndNames[$1]!.localized() }
                
                let countriesLayers = mapImage.caLayerTree.sublayers?[0].sublayers as! [CAShapeLayer]
                if let newCountryLayer = countriesLayers.first(where: { $0.name! == countryCode } ) {
                    newCountryLayer.fillColor = UIColor.blue.cgColor
                }
                
                let visitedRegions = User.sharedInstance.visitedRegions
                let visitedCountriesInRegion = region.visitedCountries//User.sharedInstance.visitedCountriesCodes(in: region)
                let section = visitedRegions.index(of: region)!
                
                if existingSection {
                    //tableViewVisitedCountries.insertRows(at: [IndexPath(row: visitedCountriesInRegion.index(of: countryCode)!, section: section)], with: .automatic)
                    //let indexPath = IndexPath(row: visitedCountriesInRegion.index, section: <#T##Int#>)
                    tableViewVisitedCountries.insertRows(at: [IndexPath(row: visitedCountriesInRegion.index(of: country)!, section: section)], with: .automatic)
                } else {
                    tableViewVisitedCountries.insertSections(IndexSet(integer: section), with: .automatic)
                }
                
                updateNumberOfVisitedCountriesAnimated()
                
                if let header = tableViewVisitedCountries.headerView(forSection: section) as? VisitedRegionHeaderView {
                    configureVisitedCountriesNumberAnimated(for: header, in: section)
                }
            }
        }
    }
    
    // MARK: - UI updates
    func updateNumberOfVisitedCountriesAnimated() {
        UIView.transition(with: labelVisitedCountries,
                                  duration: 0.3,
                                  options: [.transitionCrossDissolve],
                                  animations: {
                                    //self.labelVisitedCountries.text = self.visitedCountriesText.localized(for: User.sharedInstance.visitedCountriesCodes.count)
                                    self.labelVisitedCountries.text = self.visitedCountriesText.localized(for: User.sharedInstance.visitedCountries.count)
        }, completion: nil)
    }
    
    func configureVisitedCountriesNumber(for header: VisitedRegionHeaderView, in section: Int) {
        //header.labelVisitedCountriesNumber.text = "\(tableViewVisitedCountries.numberOfRows(inSection: section))/\(User.sharedInstance.visitedRegions[section].countriesCodes.count)"
        header.labelVisitedCountriesNumber.text = "\(tableViewVisitedCountries.numberOfRows(inSection: section))/\(User.sharedInstance.visitedRegions[section].visitedCountries.count)"
    }
    
    func configureVisitedCountriesNumberAnimated(for header: VisitedRegionHeaderView, in section: Int) {
        UIView.transition(with: header.labelVisitedCountriesNumber,
                          duration: 0.3,
                          options: [.transitionCrossDissolve],
                          animations: {
                            self.configureVisitedCountriesNumber(for: header, in: section)
        }, completion: nil)
    }
}


// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return User.sharedInstance.visitedRegions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let visitedCountriesInSection = User.sharedInstance.visitedCountriesCodes.filter { User.sharedInstance.visitedRegions[section].countriesCodes.contains($0) }
        //return visitedCountriesInSection.count
        return User.sharedInstance.visitedRegions[section].visitedCountries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewVisitedCountries.dequeueReusableCell(withIdentifier: "VisitedCountryItemCell") as! VisitedCountryItemCell
        
        //let visitedCountriesInSection = User.sharedInstance.visitedCountriesCodes.filter { User.sharedInstance.visitedRegions[indexPath.section].countriesCodes.contains($0) }
        let visitedCountriesInSection = User.sharedInstance.visitedRegions[indexPath.section].visitedCountries
        let country = visitedCountriesInSection[indexPath.row]
        //cell.labelCountryName.text = Countries.codesAndNames[visitedCountriesInSection[indexPath.row]]?.localized()
        cell.labelCountryName.text = country.code.localized()
        //cell.countryCode = visitedCountriesInSection[indexPath.row]
        cell.country = country
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let cell = tableViewVisitedCountries.cellForRow(at: indexPath) as! VisitedCountryItemCell
            //let countryCode = cell.countryCode!
            let country = cell.country!
            
            //User.sharedInstance.visitedCountriesCodes.removeObject(countryCode)
            //User.sharedInstance.visitedCountries.removeObject(country)
            User.sharedInstance.removeCountryVisit(country: country)
            
            let countriesLayers = mapImage.caLayerTree.sublayers?[0].sublayers as! [CAShapeLayer]
            //if let deletedCountryLayer = countriesLayers.first(where: { $0.name! == countryCode } ) {
            if let deletedCountryLayer = countriesLayers.first(where: { $0.name! == country.code } ) {
                deletedCountryLayer.fillColor = UIColor.countryDefaultColor.cgColor
            }
            
            if tableViewVisitedCountries.numberOfRows(inSection: indexPath.section) == 1 {
                tableViewVisitedCountries.deleteSections([indexPath.section], with: .automatic)
            } else {
                tableViewVisitedCountries.deleteRows(at: [indexPath], with: .automatic)
            }
            
            if let header = tableViewVisitedCountries.headerView(forSection: indexPath.section) as? VisitedRegionHeaderView {
                configureVisitedCountriesNumberAnimated(for: header, in: indexPath.section)
            }
            
            updateNumberOfVisitedCountriesAnimated()
        }
    }

}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableViewVisitedCountries.dequeueReusableHeaderFooterView(withIdentifier: "VisitedRegionHeaderView") as! VisitedRegionHeaderView
        header.labelRegionName.text = User.sharedInstance.visitedRegions[section].code.localized() //User.sharedInstance.visitedRegions[section].name
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

