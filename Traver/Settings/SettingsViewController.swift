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
                            self.showAlertAllowAccessToPhotos()
                        }
                    })
                case .denied:
                    showAlertAllowAccessToPhotos()
                case .restricted:
                    showAlertRestrictedAccess()
                }
            default: ()
            }
        }
    }
    
    func showAlertAllowAccessToPhotos() {
        let alert = UIAlertController(title: "Import is impossible".localized(), message: "Please allow Traver to access Photos".localized(), preferredStyle: UIAlertControllerStyle.alert)
        let settingsAction = UIAlertAction(title: "Go to Settings".localized(), style: .default) { (action) in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        let dontAllowAction = UIAlertAction(title: "Don't Allow".localized(), style: .cancel)
        alert.addAction(dontAllowAction)
        alert.addAction(settingsAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertRestrictedAccess() {
        let alert = UIAlertController(title: "Access to Photos is restricted", message: "We can't import visited countries from your Photos as parental controls or institutional configuration profiles restrict your ability to grant photo library access to apps".localized(), preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "OK".localized(), style: .cancel)
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
    }
}
