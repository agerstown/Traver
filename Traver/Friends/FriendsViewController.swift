//
//  FriendsViewController.swift
//  Traver
//
//  Created by Natalia Nikitina on 4/15/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation
import CoreData
import FacebookCore
import FacebookLogin
import CoreLocation

class FriendsViewController: UIViewController {
    
    @IBOutlet var tableViewFriends: UITableView!
    @IBOutlet weak var viewNoFriends: UIView!
    @IBOutlet weak var labelNobodysHere: UILabel!
    @IBOutlet weak var labelNoFriendsText: UILabel!
    @IBOutlet weak var buttonConnectFacebook: UIButton!
    
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var viewInnerHeader: UIView!
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var labelCurrentLocation: UILabel!
    @IBOutlet weak var labelFriendsInfo: UILabel!
    
    let gestureRecognizerLabelCurrentLocation = UITapGestureRecognizer()
    
    var fetchedResultsController: NSFetchedResultsController<User>?
    
    let refreshControl = UIRefreshControl()
    
    let visitedCountriesText = "%d countries visited"
    
    //let locationManager = CLLocationManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Friends".localized()
        
        tableViewFriends.dataSource = self
        tableViewFriends.delegate = self
        
        tableViewFriends.tableFooterView = UIView()
        
        fetchedResultsController?.delegate = self
        
        let predicate = NSPredicate(format: "ANY friends = %@", User.shared)
        let fetchRequest = NSFetchRequest<User> (entityName: "User")
        fetchRequest.predicate = predicate
        let countriesNumSortDescriptor = NSSortDescriptor(key: "numberOfVisitedCountries", ascending: false)
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [countriesNumSortDescriptor, nameSortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        try! fetchedResultsController!.performFetch()
        
        configureView()
        
        UserApiManager.shared.getFriends(user: User.shared)
        
        refreshControl.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        tableViewFriends.refreshControl = refreshControl
        
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        NotificationCenter.default.addObserver(self, selector: #selector(friendsUpdated), name: UserApiManager.shared.FriendsUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(photoUpdated), name: UserApiManager.shared.PhotoUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(facebookConnected), name: UserApiManager.shared.ProfileInfoUpdatedNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    @IBAction func buttonConnectFacebookTapped(_ sender: Any) {
        if AccessToken.current == nil {
            FacebookHelper.shared.login()
        } else {
            UserApiManager.shared.getFriends(user: User.shared)
        }
    }
    
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        UserApiManager.shared.getFriends(user: User.shared) {
            refreshControl.endRefreshing()
        }
    }
    
    @objc func labelCurrentLocationTapped() {
        performSegue(withIdentifier: "segueToCurrentLocationController", sender: nil)
//        if CLLocationManager.authorizationStatus() == .notDetermined {
//            locationManager.requestAlwaysAuthorization()
//        } else {
//            performSegue(withIdentifier: "segueToCurrentLocationController", sender: nil)
//        }
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? CurrentLocationController {
            controller.currentLocationDelegate = self
            controller.backgroundImage = Bluring.blurBackground(backgroundController: self)
        }
    }
    
    // MARK: - Notifications
    @objc func friendsUpdated() {
        try! fetchedResultsController!.performFetch()
        
        configureView()
        tableViewFriends.reloadData()
        
        if let currentCountryCode = User.shared.currentCountryCode {
            UserApiManager.shared.getFriendsForCurrentCountry(code: currentCountryCode) { friendsNames in
                self.configureFriendsInfoLabel(names: friendsNames)
            }
        }
    }
    
    @objc func facebookConnected() {
        UserApiManager.shared.getFriends(user: User.shared)
    }
    
    @objc func photoUpdated() {
        imageViewPhoto.image = User.shared.photo
    }

    // MARK: - UI
    func configureView() {
        
        if User.shared.friends.count > 0 {
            tableViewFriends.isHidden = false
            viewNoFriends.isHidden = true
            
            gestureRecognizerLabelCurrentLocation.addTarget(self, action: #selector(labelCurrentLocationTapped))
            labelCurrentLocation.isUserInteractionEnabled = true
            labelCurrentLocation.addGestureRecognizer(gestureRecognizerLabelCurrentLocation)
            
            viewInnerHeader.layer.cornerRadius = 5
            imageViewPhoto.layer.cornerRadius = imageViewPhoto.frame.height / 2
            imageViewPhoto.image = User.shared.photo ?? #imageLiteral(resourceName: "default_photo")
            
            labelCurrentLocation.layer.cornerRadius = 5
            labelCurrentLocation.layer.borderColor = UIColor.lightGray.cgColor
            
            configureCurrentLocationLabel()
        } else {
            tableViewFriends.isHidden = true
            viewNoFriends.isHidden = false
            labelNobodysHere.text = "Nobody's here :(".localized()
            
            buttonConnectFacebook.layer.cornerRadius = 5
            
            if AccessToken.current == nil { //User.shared.facebookID == nil
                labelNoFriendsText.text = "Connect your Facebook to see your friends".localized()
                buttonConnectFacebook.setTitle("Connect".localized(), for: .normal)
            } else {
                labelNoFriendsText.text = "Invite your friends to use Traver!".localized()
                buttonConnectFacebook.setTitle("Update".localized(), for: .normal)
            }
        }
    }
    
    func configureCurrentLocationLabel() {
        if User.shared.currentCountryCode != nil {
            labelCurrentLocation.layer.borderWidth = 0
            labelCurrentLocation.textAlignment = .left
            labelCurrentLocation.text = "Currently in ".localized() + User.shared.currentLocation!
        } else {
            labelCurrentLocation.layer.borderWidth = 1
            labelCurrentLocation.textAlignment = .center
            labelCurrentLocation.text = "Set current location".localized()
        }
    }
    
    func configureFriendsInfoLabel(names: [String]) {
        if names.count > 0 {
            viewHeader.frame.size.height = 120
            labelFriendsInfo.isHidden = false
            tableViewFriends.reloadData()
            
            var text = names[0]
            
            if names.count > 1 {
                if names.count > 2 {
                    text += ", " + names[1] + " and2 ".localized() + "\(names.count - 2)" + " more have been there.".localized()
                } else {
                    text += " and ".localized() + names[1] + " have been there.".localized()
                }
            } else {
                text += " has been there.".localized()
            }
            
            labelFriendsInfo.text = text
            
        } else {
            viewHeader.frame.size.height = 76
            labelFriendsInfo.isHidden = true
            tableViewFriends.reloadData()
        }
    }
    
}

// MARK: - UITableViewDataSource
extension FriendsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewFriends.dequeue(FriendCell.self)
        configureCell(cell, at: indexPath)
        return cell
    }
    
    func configureCell(_ cell: FriendCell, at indexPath: IndexPath) {
        let user =  fetchedResultsController!.object(at: indexPath)
        
        cell.labelName.text = user.name
        
        if let path = user.photoPath {
            cell.imageViewPhoto.image = UIImage(named: "default_photo")
            ImagesManager.shared.loadImage(withURL: UserApiManager.shared.photosHost + "traver-media/" + path, intoImageView: cell.imageViewPhoto)
        } else {
            cell.imageViewPhoto.image = #imageLiteral(resourceName: "default_photo") 
        }
        
        if let location = user.currentLocation {
            cell.labelCurrentLocation.text = "Currently in ".localized() + location
            cell.constraintLabelName.constant = 6
        } else {
            cell.labelCurrentLocation.text = nil
            cell.constraintLabelName.constant = 18
        }
        
        if let numberOfVisitedCountries = user.numberOfVisitedCountries {
          cell.labelVisitedCountries.text =  visitedCountriesText.localized(for: Int(truncating: numberOfVisitedCountries))
        }
    }
}

// MARK: - UITableViewDelegate
extension FriendsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user =  fetchedResultsController!.object(at: indexPath)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            controller.user = user
            CountryVisitApiManager.shared.getUserCountryVisits(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        tableViewFriends.deselectRow(at: indexPath, animated: true)
    }

}

// MARK: - NSFetchedResultsControllerDelegate
extension FriendsViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let newPath = newIndexPath {
                tableViewFriends.insertRows(at: [newPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableViewFriends.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                if let cell = tableViewFriends.cellForRow(at: indexPath) as? FriendCell {
                    configureCell(cell, at: indexPath)
                }
            }
        default: ()
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableViewFriends.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableViewFriends.endUpdates()
    }
}

// MARK: - CurrentLocationDelegate
extension FriendsViewController: CurrentLocationDelegate {
    func locationSaved() {
        configureCurrentLocationLabel()
    }
    
    func friendsNamesDownloaded(names: [String]) {
        configureFriendsInfoLabel(names: names)
    }
}

//// MARK: - CLLocationManagerDelegate
//extension FriendsViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .authorizedAlways {
//            locationManager.startMonitoringSignificantLocationChanges()
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.last {
//            let geocoder = CLGeocoder()
//            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
//                if let placemark = placemarks?.first {
//                    if let code = placemark.isoCountryCode {
//                        if Codes.Country.all.contains(where: { $0.code == code } ) {
//                            let region = placemark.locality
//                            UserApiManager.shared.setCurrentLocation(countryCode: code, region: region) {
//                                self.configureCurrentLocationLabel()
//                            }
//                            UserApiManager.shared.getFriendsForCurrentCountry(code: code) { friendsNames in
//                                self.configureFriendsInfoLabel(names: friendsNames)
//                            }
//                        }
//                    }
//                }
//            })
//        }
//    }
//}
