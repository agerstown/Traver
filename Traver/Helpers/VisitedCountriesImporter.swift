//
//  VisitedCountriesImporter.swift
//  Traver
//
//  Created by Natalia Nikitina on 12/2/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation
import Photos

class VisitedCountriesImporter {
    
    static let sharedInstance = VisitedCountriesImporter()
    
    static let isAlreadyImported = "isAlreadyImported"
    
    // MARK: - Import from Photos
    func fetchVisitedCountriesCodesFromPhotos() {
        DispatchQueue.global().async { [weak self] in
            var momentsLocations = [CLLocation]()
            let moments = PHAssetCollection.fetchMoments(with: nil)
            moments.enumerateObjects({ (moment, index, error) -> Void in
                if let location = moment.approximateLocation {
                    momentsLocations.append(location)
                }
            })
            
            var roundedLocations = [CLLocation]()
            
            for location in momentsLocations {
                let roundedLocation = CLLocation(latitude: location.coordinate.latitude.roundTo(places: 0), longitude: location.coordinate.longitude.roundTo(places: 0))
                if !roundedLocations.contains(where: { $0.coordinate.latitude == roundedLocation.coordinate.latitude && $0.coordinate.longitude == roundedLocation.coordinate.longitude }) {
                    roundedLocations.append(roundedLocation)
                    self?.locations.append(location)
                }
            }
            
            let geocoder = CLGeocoder()
            self?.getCountriesCodesFromLocations(using: geocoder)
        }
    }
    
    private var locationsCounter = 0
    private var locations = [CLLocation]()
    private var countriesCodes = [String]()
    
    // only one reverseGeocodeLocation:completionHandler: request can be initiated at a time so the the sequence of requests is initiated using recursion
    private func getCountriesCodesFromLocations(using geocoder: CLGeocoder) {
        if locationsCounter == locations.count {
            NotificationCenter.default.post(name: VisitedCountriesImporter.ImportFinishedNotification,
                                            object: nil,
                                            userInfo: [VisitedCountriesImporter.ImportedCountriesInfoKey : countriesCodes])
            UserDefaults.standard.set(true, forKey: VisitedCountriesImporter.isAlreadyImported)
            return
        }
        geocoder.reverseGeocodeLocation(locations[locationsCounter], completionHandler: { [weak self] (placemarks, error) in
            
            if error != nil {
                return
            }
            
            if let placemarks = placemarks {
                if let code = placemarks[0].isoCountryCode {
                    if let existingCode = self?.countriesCodes.contains(code) {
                        if !existingCode {
                            self?.countriesCodes.append(code)
                            NotificationCenter.default.post(name: VisitedCountriesImporter.CountryCodeImportedNotification,
                                                            object: nil,
                                                            userInfo: [VisitedCountriesImporter.CountryCodeInfoKey : code])
                        }
                    }
                }
            }
            
            self?.locationsCounter += 1
            
            _ = self?.getCountriesCodesFromLocations(using: geocoder)
        })
    }

    // MARK: - Notifications
    static let CountryCodeImportedNotification = NSNotification.Name(rawValue: "CountryCodeImportedNotification")
    static let ImportFinishedNotification = NSNotification.Name(rawValue:"ImportFinishedNotification")
    
    static let CountryCodeInfoKey = "CountryCodeInfoKey"
    static let ImportedCountriesInfoKey = "ImportedCountriesInfoKey"
    
}
