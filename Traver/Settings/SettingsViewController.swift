//
//  SettingsViewController.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/21/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation
import Photos
import FacebookCore
import FacebookLogin

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var tableViewSettings: UITableView!
    @IBOutlet weak var cellImportFromPhotos: UITableViewCell!
    @IBOutlet weak var cellFacebook: UITableViewCell!
    @IBOutlet weak var celliCloud: UITableViewCell!
    
    let sectionsHeaders = ["Import".localized(), "Accounts".localized()];
    let sectionsFooters = ["It may take some time, just wait a little.".localized(), ""];
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings".localized()
        
        cellImportFromPhotos.textLabel?.text = "Import countries from Photos".localized()
        
        cellFacebook.textLabel?.text = "Facebook".localized()
        cellFacebook.detailTextLabel?.text = User.shared.facebookID != nil ? "Connected" : "Not connected"
        
        celliCloud.textLabel?.text = "iCloud".localized()
        celliCloud.detailTextLabel?.text = User.shared.iCloudID != nil ? "Connected" : "Not connected"
        
        tableViewSettings.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(profileInfoUpdated), name: UserApiManager.shared.ProfileInfoUpdatedNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsHeaders[section]
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sectionsFooters[section]
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewSettings.deselectRow(at: indexPath, animated: true)
        if let cell = tableViewSettings.cellForRow(at: indexPath) {
            switch (cell) {
            case cellImportFromPhotos:
                PhotosAccessManager.shared.importVisitedCountries(controller: self)
            case cellFacebook:
                FacebookHelper.shared.login()
            case celliCloud:
                CloudKitHelper.shared.login()
            default: ()
            }
        }
    }
    
    // MARK: - Notifications
    func profileInfoUpdated() {
        cellFacebook.detailTextLabel?.text = User.shared.facebookID != nil ? "Connected" : "Not connected"
        celliCloud.detailTextLabel?.text = User.shared.iCloudID != nil ? "Connected" : "Not connected"
        self.tableViewSettings.reloadData()
    }
}
