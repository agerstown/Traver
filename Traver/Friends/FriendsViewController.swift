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
        let sortDescriptor = NSSortDescriptor(key: "numberOfVisitedCountries", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        try! fetchedResultsController!.performFetch()
        
        UserApiManager.shared.getFriends(user: User.shared)
        
        refreshControl.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        tableViewFriends.refreshControl = refreshControl
        
        configureView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(friendsUpdated), name: UserApiManager.shared.FriendsUpdatedNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    @IBAction func buttonConnectFacebookTapped(_ sender: Any) {
        if AccessToken.current == nil {
            FacebookHelper.shared.login()
        } else {
            UserApiManager.shared.getFriends(user: User.shared) {
                try! self.fetchedResultsController!.performFetch()
                self.tableViewFriends.reloadData()
            }
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        UserApiManager.shared.getFriends(user: User.shared) {
            refreshControl.endRefreshing()
        }
    }
    
    func labelCurrentLocationTapped() {
        performSegue(withIdentifier: "segueToCurrentLocationController", sender: nil)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? CurrentLocationController {
            controller.currentLocationDelegate = self
            controller.backgroundImage = Bluring.blurBackground(backgroundController: self)
        }
    }
    
    // MARK: - Notifications
    func friendsUpdated() {
        try! fetchedResultsController!.performFetch()
        configureView()
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
            imageViewPhoto.image = User.shared.photo
            
            labelCurrentLocation.adjustsFontSizeToFitWidth = true
            
            labelCurrentLocation.layer.cornerRadius = 5
            labelCurrentLocation.layer.borderColor = UIColor.gray.cgColor
            
            configureCurrentLocationLabel()
            
            labelFriendsInfo.adjustsFontSizeToFitWidth = true
            
            if let currentCountryCode = User.shared.currentCountryCode {
                UserApiManager.shared.getFriendsForCurrentCountry(code: currentCountryCode) { friendsNames in
                    self.configureFriendsInfoLabel(names: friendsNames)
                }
            }
            
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
            labelCurrentLocation.text = User.shared.currentLocation
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
            
            var text = "\u{2022} " + names[0]
            
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
        let cell = tableViewFriends.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendCell
        configureCell(cell, at: indexPath)
        return cell
    }
    
    func configureCell(_ cell: FriendCell, at indexPath: IndexPath) {
        let user =  fetchedResultsController!.object(at: indexPath)
        
        cell.labelName.text = user.name
        cell.imageViewPhoto.image = user.photo != nil ? user.photo : UIImage(named: "default_photo")
        if let location = user.currentLocation {
            cell.labelCurrentLocation.text = "Currently in ".localized() + location
        } else {
            cell.labelCurrentLocation.text = nil
        }
        
        if user.visitedCountries.count > 0 {
            user.numberOfVisitedCountries = String(user.visitedCountries.count)
            CoreDataStack.shared.saveContext()
        }
        
        if let numberOfVisitedCountriesString = user.numberOfVisitedCountries {
            if let number = Int(numberOfVisitedCountriesString) {
                cell.labelVisitedCountries.text =  visitedCountriesText.localized(for: number)
            }
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
            UserApiManager.shared.getUserCountryVisits(user: user)
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
