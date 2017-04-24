//
//  ProfileViewController.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/21/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation
import Photos
import CoreData
import Alamofire

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
    @IBOutlet weak var buttonShare: UIButton!
    
    @IBOutlet weak var constraintScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintButtonFillInfo: NSLayoutConstraint!
    
    var mapImage: SVGKImage = SVGKImage(named: "WorldMap.svg")!
    
    let visitedCountriesText = "%d/176 countries visited"
    let mapHeightToWidthRatio: CGFloat = 1.5
    
    let refreshControl = UIRefreshControl()
    
    var fetchedResultsController: NSFetchedResultsController<Country>?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Profile".localized()
        buttonEditUserInfo.setTitle(" " + "Edit".localized(), for: .normal)
        buttonFillInfo.setTitle("Fill profile info".localized(), for: .normal)
        
        let nib = UINib(nibName: "VisitedRegionHeaderView", bundle: nil)
        tableViewVisitedCountries.register(nib, forHeaderFooterViewReuseIdentifier: "VisitedRegionHeaderView")
        
        tableViewVisitedCountries.dataSource = self
        tableViewVisitedCountries.delegate = self
        scrollView.delegate = self
        
        labelName.adjustsFontSizeToFitWidth = true
        labelLocation.adjustsFontSizeToFitWidth = true
        labelVisitedCountries.adjustsFontSizeToFitWidth = true
        buttonEditUserInfo.titleLabel?.adjustsFontSizeToFitWidth = true
        
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
        
        refreshControl.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        tableViewVisitedCountries.refreshControl = refreshControl
        
        let predicate = NSPredicate(format: "ANY users = %@", User.shared)
        let fetchRequest = NSFetchRequest<Country> (entityName: "Country")
        fetchRequest.predicate = predicate
        let regionSortDescriptor = NSSortDescriptor(key: "region.index", ascending: true)
        let countrySortDescriptor = NSSortDescriptor(key: "name", ascending: true) //, selector: bla)
        fetchRequest.sortDescriptors = [regionSortDescriptor, countrySortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: "region.index", cacheName: nil)
        
        try! fetchedResultsController!.performFetch()
        
        fetchedResultsController?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(countryCodeImported(notification:)), name: VisitedCountriesImporter.shared.CountryCodeImportedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(countriesUpdated), name: UserApiManager.shared.CountriesUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(profileInfoUpdated), name: UserApiManager.shared.ProfileInfoUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(photoUpdated), name: UserApiManager.shared.PhotoUpdatedNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateProfileInfo()
        updateCountriesRelatedInfo()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Actions
    @IBAction func buttonFillInfoTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "How do you want to fill your info?".localized(), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Connect Facebook".localized(), style: .default) { _ in
            FacebookHelper.shared.login()
        })
        alert.addAction(UIAlertAction(title: "Fill manually".localized(), style: .default) { _ in
            self.performSegue(withIdentifier: "segueToEditProfile", sender: nil)
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        self.present(alert, animated: true)
    }
    
    func updateProfileInfo() {
        if User.shared.name != nil && User.shared.name != "" {
            buttonFillInfo.isHidden = true
            buttonShare.isHidden = false
            constraintButtonFillInfo.constant = 66
        } else {
            buttonFillInfo.isHidden = false
            buttonShare.isHidden = true
            constraintButtonFillInfo.constant = 16
        }
        
        labelName.text = User.shared.name
        labelLocation.text = User.shared.location
        
        imageViewPhoto.image = User.shared.photo != nil ? User.shared.photo : UIImage(named: "default_photo")
    }
    
    func updateCountriesRelatedInfo() {
        mapImage.colorVisitedCounties()
        tableViewVisitedCountries.reloadData()
        labelVisitedCountries.text = visitedCountriesText.localized(for: User.shared.visitedCountries.count)
    }
    
    func updatePhoto() {
        imageViewPhoto.image = User.shared.photo != nil ? User.shared.photo : UIImage(named: "default_photo")
    }
    
    @IBAction func buttonEditTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueToEditProfile", sender: nil)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        if User.shared.token != nil && User.shared.token != "" {
            UserApiManager.shared.getUserInfo(user: User.shared) { _ in
                refreshControl.endRefreshing()
            }
        } else {
            refreshControl.endRefreshing()
        }
    }

    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController {
            if let controller = navController.viewControllers[0] as? CountriesViewController {
                controller.selectedCountries = Codes.Country.all.filter { (country) in
                    User.shared.visitedCountriesArray.contains(where: { $0.code == country.code })
                }
            }
        } else if let controller = segue.destination as? SharePreviewController {
            controller.backgroundController = self
        }
    }

    // MARK: - Notifications
    func countryCodeImported(notification: NSNotification) {
        if let countryCode = notification.userInfo?[VisitedCountriesImporter.shared.CountryCodeInfoKey] as? String {
            if !User.shared.visitedCountriesArray.contains(where: { $0.code == countryCode }) {
                UserApiManager.shared.addCountryVisit(code: countryCode) {
                    let countriesLayers = self.mapImage.caLayerTree.sublayers?[0].sublayers as! [CAShapeLayer]
                    if let newCountryLayer = countriesLayers.first(where: { $0.name! == countryCode } ) {
                        newCountryLayer.fillColor = UIColor.blue.cgColor
                    }
                    
                    self.updateNumberOfVisitedCountriesAnimated()
                }
            }
        }
    }
    
    func countriesUpdated() {
        updateCountriesRelatedInfo()
    }
    
    func profileInfoUpdated() {
        updateProfileInfo()
    }
    
    func photoUpdated() {
        updatePhoto()
    }
    
    // MARK: - UI updates
    func updateNumberOfVisitedCountriesAnimated() {
        UIView.transition(with: labelVisitedCountries,
                                  duration: 0.3,
                                  options: [.transitionCrossDissolve],
                                  animations: {
                                    self.labelVisitedCountries.text = self.visitedCountriesText.localized(for: User.shared.visitedCountries.count)
        }, completion: nil)
    }
    
    func configureVisitedCountriesNumber(for header: VisitedRegionHeaderView, in section: Int) {
        let numberOfCountriesInSection = fetchedResultsController?.sections?[section].numberOfObjects
        if let numberOfCountriesInSection = numberOfCountriesInSection {
            header.labelVisitedCountriesNumber.text = "\(numberOfCountriesInSection)/\(Codes.regions[section].1.count)"
        }
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
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewVisitedCountries.dequeueReusableCell(withIdentifier: "VisitedCountryItemCell") as! VisitedCountryItemCell
        
        let country =  fetchedResultsController!.object(at: indexPath)
        
        cell.labelCountryName.text = country.code.localized()
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
            
            let country = cell.country!
            let code = country.code
            
            UserApiManager.shared.deleteCountryVisit(country: country) {
                
                let countriesLayers = self.mapImage.caLayerTree.sublayers?[0].sublayers as! [CAShapeLayer]
                if let deletedCountryLayer = countriesLayers.first(where: { $0.name! == code } ) {
                    deletedCountryLayer.fillColor = UIColor.countryDefaultColor.cgColor
                }
                
                self.updateNumberOfVisitedCountriesAnimated()
            }
        }
    }

}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableViewVisitedCountries.dequeueReusableHeaderFooterView(withIdentifier: "VisitedRegionHeaderView") as! VisitedRegionHeaderView
        configureVisitedCountriesNumber(for: header, in: section)
        if let sections = fetchedResultsController?.sections {
            if let regionIndex = Int(sections[section].name) {
                if let region = Codes.Region(rawValue: regionIndex) {
                    header.labelRegionName.text = region.code.localized()
                }
            }
        }
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

// MARK: - NSFetchedResultsControllerDelegate
extension ProfileViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch(type) {
        case .insert:
            tableViewVisitedCountries.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableViewVisitedCountries.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default: ()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let newPath = newIndexPath {
                tableViewVisitedCountries.insertRows(at: [newPath], with: .automatic)
                
                if let header = self.tableViewVisitedCountries.headerView(forSection: newPath.section) as? VisitedRegionHeaderView {
                    configureVisitedCountriesNumberAnimated(for: header, in: newPath.section)
                }

                
            }
        case .delete:
            if let indexPath = indexPath {
                tableViewVisitedCountries.deleteRows(at: [indexPath], with: .automatic)
                
                if let header = self.tableViewVisitedCountries.headerView(forSection: indexPath.section) as? VisitedRegionHeaderView {
                    configureVisitedCountriesNumberAnimated(for: header, in: indexPath.section)
                }
                
            }
        default: ()
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableViewVisitedCountries.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableViewVisitedCountries.endUpdates()
    }

}

