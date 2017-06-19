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

    var user: User?
    
    @IBOutlet weak var tableViewVisitedCountries: UITableView!
    @IBOutlet weak var viewTableViewHeader: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var viewUserInfo: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelLocation: UILabel!
    @IBOutlet weak var labelVisitedCountries: UILabel!
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var buttonAddCountries: UIBarButtonItem!
    @IBOutlet weak var buttonEditUserInfo: UIButton!
    @IBOutlet weak var buttonFillInfo: UIButton!
    @IBOutlet weak var buttonShare: UIButton!
    
    @IBOutlet weak var constraintScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintButtonFillInfo: NSLayoutConstraint!
    @IBOutlet weak var constraintPhotoBottom: NSLayoutConstraint!
    
    var mapImage: SVGKImage = SVGKImage(named: "WorldMap.svg")!
    
    let visitedCountriesText = "%d/180 countries visited"
    let mapHeightToWidthRatio: CGFloat = 1.5
    
    let refreshControl = UIRefreshControl()
    
    var fetchedResultsController: NSFetchedResultsController<Country>?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureButtonsForUser()
        
        self.title = "Profile".localized()
        buttonEditUserInfo.setTitle(" " + "Edit".localized(), for: .normal)
        buttonFillInfo.setTitle("Fill profile info".localized(), for: .normal)
        
        let nib = UINib(nibName: "VisitedRegionHeaderView", bundle: nil)
        tableViewVisitedCountries.register(nib, forHeaderFooterViewReuseIdentifier: "VisitedRegionHeaderView")
        
        tableViewVisitedCountries.dataSource = self
        tableViewVisitedCountries.delegate = self
        scrollView.delegate = self
        
        buttonEditUserInfo.titleLabel?.adjustsFontSizeToFitWidth = true
        
        buttonFillInfo.layer.cornerRadius = 5
        buttonFillInfo.layer.borderWidth = 1
        buttonFillInfo.layer.borderColor = UIColor.black.cgColor
        
        imageViewPhoto.layer.cornerRadius = imageViewPhoto.frame.height / 2
        
        // setting up the scroll view and table view header sizes
        scrollView.frame.size.width = UIScreen.main.bounds.width
        constraintScrollViewHeight.constant = scrollView.frame.width / mapHeightToWidthRatio
        viewTableViewHeader.frame.size.height = constraintScrollViewHeight.constant + viewUserInfo.frame.height
        
        // setting up the map and it's size
        let width = scrollView.frame.width
        let scale = width / mapImage.size.width
        let height = mapImage.size.height * scale
        mapImage.size = CGSize(width: width, height: height)
        if let imageView = SVGKLayeredImageView(svgkImage: mapImage) {
            viewMap.addSubview(imageView)
        }
        
        refreshControl.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        tableViewVisitedCountries.refreshControl = refreshControl
        
        let predicate = NSPredicate(format: "ANY users = %@", user!)
        let fetchRequest = NSFetchRequest<Country> (entityName: "Country")
        fetchRequest.predicate = predicate
        let regionSortDescriptor = NSSortDescriptor(key: "region.index", ascending: true)
        let countrySortDescriptor = NSSortDescriptor(key: "name", ascending: true) 
        fetchRequest.sortDescriptors = [regionSortDescriptor, countrySortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: "region.index", cacheName: nil)
        
        fetchedResultsController?.delegate = self
        
        try! fetchedResultsController!.performFetch()
        
        NotificationCenter.default.addObserver(self, selector: #selector(profileInfoUpdated), name: UserApiManager.shared.ProfileInfoUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(photoUpdated), name: UserApiManager.shared.PhotoUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(countryCodeImported(notification:)), name: VisitedCountriesImporter.shared.CountryCodeImportedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(countriesUpdated), name: user!.CountriesUpdatedNotification, object: nil)
        
        //showAgreementAlert()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateProfileInfo()
        updateCountriesRelatedInfo()
        updatePhoto()
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
        if user!.name != nil && user!.name != "" {
            buttonFillInfo.isHidden = true
            buttonShare.isHidden = user == User.shared ? false : true
            constraintButtonFillInfo.constant = 66
        } else {
            buttonFillInfo.isHidden = false
            buttonShare.isHidden = true
            constraintButtonFillInfo.constant = 16
        }
        
        labelName.text = user!.name
        labelLocation.text = user!.location
    }
    
    func updateCountriesRelatedInfo() {
        mapImage.colorVisitedCounties(for: user!)
        tableViewVisitedCountries.reloadData()
        labelVisitedCountries.text = visitedCountriesText.localized(for: user!.visitedCountries.count)
    }
    
    func updatePhoto() {
        if user == User.shared {
            imageViewPhoto.image = user!.photo != nil ? user!.photo : UIImage(named: "default_photo")
        } else {
            imageViewPhoto.image = UIImage(named: "default_photo")
            if let path = user!.photoPath {
                ImagesManager.shared.loadImage(withURL: UserApiManager.shared.photosHost + "traver-media/" + path,
                                           intoImageView: imageViewPhoto)
            }
        }
    }
    
    @IBAction func buttonEditTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueToEditProfile", sender: nil)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        if user!.token != nil && user!.token != "" {
            UserApiManager.shared.getUserInfo(user: user!) { _ in
                refreshControl.endRefreshing()
            }
        } else {
            refreshControl.endRefreshing()
        }
    }
    
//    func showAgreementAlert() {
//        if UserDefaults.standard.object(forKey: "agreedToTerms") as? Bool == nil {
//            if let tips = User.shared.tips {
//                UserDefaults.standard.set(tips.count > 0, forKey: "agreedToTerms")
//            } else {
//                UserDefaults.standard.set(false, forKey: "agreedToTerms")
//            }
//        }
//        
//        if let agreedToTerms = UserDefaults.standard.object(forKey: "agreedToTerms") as? Bool {
//            if !agreedToTerms {
//                let alert = UIAlertController(title: "Agreement".localized(), message: "In Traver you can write travel tips for other users.".localized() + " " + "Please confirm that you agree to the EULA terms and will not post any objectionable or abusive content".localized(), preferredStyle: UIAlertControllerStyle.alert)
//                let agreeAction = UIAlertAction(title: "Agree".localized(), style: .default) { _ in
//                    UserDefaults.standard.set(true, forKey: "agreedToTerms")
//                }
//                let disagreeAction = UIAlertAction(title: "Disagree".localized(), style: .cancel) { _ in
//                    UserDefaults.standard.set(false, forKey: "agreedToTerms")
//                }
//                alert.addAction(agreeAction)
//                alert.addAction(disagreeAction)
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
//    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController {
            if let controller = navController.viewControllers[0] as? CountriesViewController {
                controller.selectedCountries = Codes.Country.all.filter { (country) in
                    user!.visitedCountriesArray.contains(where: { $0.code == country.code })
                }
            }
        } else if let controller = segue.destination as? SharePreviewController {
            controller.backgroundImage = Bluring.blurBackground(backgroundController: self)
        }
    }

    // MARK: - Notifications
    func countryCodeImported(notification: NSNotification) {
        if let countryCode = notification.userInfo?[VisitedCountriesImporter.shared.CountryCodeInfoKey] as? String {
            if !user!.visitedCountriesArray.contains(where: { $0.code == countryCode }) {
                CountryVisitApiManager.shared.addCountryVisit(code: countryCode) {
                    let countriesLayers = self.mapImage.caLayerTree.sublayers?[0].sublayers as! [CAShapeLayer]
                    if let newCountryLayer = countriesLayers.first(where: { $0.name! == countryCode } ) {
                        newCountryLayer.fillColor = UIColor.blueTraverColor.cgColor
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
                                    self.labelVisitedCountries.text = self.visitedCountriesText.localized(for: self.user!.visitedCountries.count)
        }, completion: nil)
    }
    
    func configureVisitedCountriesNumber(for header: VisitedRegionHeaderView, in section: Int) {
        if let numberOfCountriesInSection = fetchedResultsController?.sections?[section].numberOfObjects {
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
    
    func configureButtonsForUser() {
        if user == nil {
            user = User.shared
            
            self.navigationItem.rightBarButtonItem = buttonAddCountries
            buttonShare.isHidden = false
            buttonEditUserInfo.isHidden = false
            
            constraintPhotoBottom.constant = 32
            
        } else {
            self.navigationItem.rightBarButtonItem = nil
            buttonShare.isHidden = true
            buttonEditUserInfo.isHidden = true
            
            constraintPhotoBottom.constant = 20
        }
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
        let cell = tableViewVisitedCountries.dequeue(VisitedCountryItemCell.self)
        configureCell(cell, at: indexPath)
        return cell
    }
    
    func configureCell(_ cell: VisitedCountryItemCell, at indexPath: IndexPath) {
        let country =  fetchedResultsController!.object(at: indexPath)
        
        cell.labelCountryName.text = country.name
        cell.country = country
        cell.selectionStyle = .none
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if user == User.shared {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let cell = tableViewVisitedCountries.cellForRow(at: indexPath) as! VisitedCountryItemCell
            
            let country = cell.country!
            let code = country.code
            
            CountryVisitApiManager.shared.deleteCountryVisit(country: country) {
            
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
        let header = tableViewVisitedCountries.dequeueHeaderFooter(VisitedRegionHeaderView.self)
        configureVisitedCountriesNumber(for: header, in: section)
        if let sections = fetchedResultsController?.sections {
            if let regionIndex = Int(sections[section].name) {
                if let region = Codes.Region(rawValue: regionIndex) {
                    header.labelRegionName.text = region.name
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
            }
        case .delete:
            if let indexPath = indexPath {
                tableViewVisitedCountries.deleteRows(at: [indexPath], with: .automatic)
            }
        default: ()
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableViewVisitedCountries.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableViewVisitedCountries.endUpdates()
        
        if let sections = fetchedResultsController?.sections {
            for index in 0..<sections.count {
                if let header = self.tableViewVisitedCountries.headerView(forSection: index) as? VisitedRegionHeaderView {
                    configureVisitedCountriesNumberAnimated(for: header, in: index)
                }
            }
        }
    }

}

