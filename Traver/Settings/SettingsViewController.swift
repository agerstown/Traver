//
//  SettingsViewController.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/21/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation
import Photos

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var tableViewSettings: UITableView!
    @IBOutlet weak var cellImportFromPhotos: UITableViewCell!
    
    let sectionsHeaders = ["Import".localized()];
    let sectionsFooters = ["It may take some time, just wait a little.".localized()];
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings".localized()
        cellImportFromPhotos.textLabel?.text = "Import countries from Photos".localized()
        
        tableViewSettings.delegate = self
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
                switch (PHPhotoLibrary.authorizationStatus()) {
                case .authorized:
                    VisitedCountriesImporter.sharedInstance.fetchVisitedCountriesCodesFromPhotos()
                    StatusBarManager.sharedInstance.showCustomStatusBar(with: "Import has been started".localized())
                case .notDetermined:
                    PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                        if status ==  .authorized {
                            VisitedCountriesImporter.sharedInstance.fetchVisitedCountriesCodesFromPhotos()
                            StatusBarManager.sharedInstance.showCustomStatusBar(with: "Import has been started".localized())
                        } else {
                            PhotosAccessManager.sharedInstance.showAlertAllowAccessToPhotos(on: self, withTitle: "Import is impossible")
                        }
                    })
                case .denied:
                    PhotosAccessManager.sharedInstance.showAlertAllowAccessToPhotos(on: self, withTitle: "Import is impossible")
                case .restricted:
                    PhotosAccessManager.sharedInstance.showAlertRestrictedAccess(on: self, withMessage: "We can't import visited countries from your Photos as parental controls restrict your ability to grant Photo Library access to apps. Ask the owner to allow it.")
                }
            default: ()
            }
        }
    }
}
