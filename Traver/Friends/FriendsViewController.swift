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
    
    var fetchedResultsController: NSFetchedResultsController<User>?
    
    let refreshControl = UIRefreshControl()
    
    let visitedCountriesText = "%d countries visited"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Friends".localized()
        
        tableViewFriends.dataSource = self
        tableViewFriends.delegate = self
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(facebookConnected), name: UserApiManager.shared.FriendsUpdatedNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableViewFriends.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    @IBAction func buttonConnectFacebookTapped(_ sender: Any) {
        FacebookHelper.shared.login()
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        UserApiManager.shared.getFriends(user: User.shared) {
            refreshControl.endRefreshing()
        }
    }
    
    // MARK: - Notifications
    func facebookConnected() {
        configureView()
    }
    
    func configureView() {
        if User.shared.friends.count > 0 {
            tableViewFriends.isHidden = false
            viewNoFriends.isHidden = true
        } else {
            tableViewFriends.isHidden = true
            viewNoFriends.isHidden = false
            labelNobodysHere.text = "Nobody's here :(".localized()
            
            if AccessToken.current == nil { //User.shared.facebookID == nil
                labelNoFriendsText.text = "Connect your Facebook to see your friends".localized()
                buttonConnectFacebook.isHidden = false
                buttonConnectFacebook.setTitle("Connect".localized(), for: .normal)
                buttonConnectFacebook.layer.cornerRadius = 5
                
            } else {
                
                labelNoFriendsText.text = "Invite your friends to use Traver!".localized()
                buttonConnectFacebook.isHidden = true
            }
        }
    }
    
//    // MARK: - Segue
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let controller = segue.destination as? ProfileViewController {
//            controller.user =
//        }
//    }
    
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
        
        //var numberOfVisitedCountries: Int?
        
        if user.visitedCountries.count > 0 {
            user.numberOfVisitedCountries = String(user.visitedCountries.count)
            CoreDataStack.shared.saveContext()
            //numberOfVisitedCountries = user.visitedCountries.count
        } //else {
            if let numberOfVisitedCountriesString = user.numberOfVisitedCountries {
                if let number = Int(numberOfVisitedCountriesString) {
                    //numberOfVisitedCountries = number
                    cell.labelVisitedCountries.text =  visitedCountriesText.localized(for: number)
                }
            }
        //}
        
        //cell.labelVisitedCountries.text =  visitedCountriesText.localized(for: numberOfVisitedCountries!)
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
