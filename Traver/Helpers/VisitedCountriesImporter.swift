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
    
    static let shared = VisitedCountriesImporter()
    
    // MARK: - Notifications
    let CountryCodeImportedNotification = NSNotification.Name(rawValue: "CountryCodeImportedNotification")
    let CountryCodeInfoKey = "CountryCodeInfoKey"
    
    // MARK: - Import from Photos
    private var locationsCounter = 0
    private var locations = [CLLocation]()
    private var countriesCodes = [String]()
    
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
    
    // Only one geocoding request can be initiated at a time so the the sequence of requests is initiated using recursion
    private func getCountriesCodesFromLocations(using geocoder: CLGeocoder) {
        if locationsCounter == locations.count {
            StatusBarManager.shared.showCustomStatusBar(with: "Import from Photos is finished: %d countries were found".localized(for: countriesCodes.count))
            locationsCounter = 0
            locations.removeAll()
            countriesCodes.removeAll()
            return
        }
        
        // Geocoding requests are rate-limited for each app, so making too many requests in a short period of time may cause some of the requests to fail. There is a forced delay for that reason
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            
            geocoder.reverseGeocodeLocation((self.locations[(self.locationsCounter)]),
                                            completionHandler: { (placemarks, error) in
                
                if let code = placemarks?[0].isoCountryCode {
                    if Codes.Country.all.contains(where: { $0.code == code } ) {
                        if !self.countriesCodes.contains(code) {
                            self.countriesCodes.append(code)
                            NotificationCenter.default.post(name: self.CountryCodeImportedNotification,
                                                            object: nil,
                                                            userInfo: [self.CountryCodeInfoKey : code])
                        }
                    }
                }
                
                self.locationsCounter += 1
                
                _ = self.getCountriesCodesFromLocations(using: geocoder)
            })
        }
        
    }
    
}
