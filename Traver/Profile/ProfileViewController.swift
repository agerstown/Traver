//
//  ProfileViewController.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/21/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class ProfileViewController: UITableViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var viewUserInfo: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelJob: UILabel!
    @IBOutlet weak var labelVisitedCountriesNumber: UILabel!
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var buttonEditUserInfo: UIButton!
    @IBOutlet var tableViewVisitedCountries: UITableView!
    
    var mapImage: SVGKImage = SVGKImage(named: "WorldMap.svg")!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Profile".localized()
        scrollView.delegate = self
        imageViewPhoto.layer.cornerRadius = imageViewPhoto.frame.height / 2
        
        // setting up the map's size
        mapImage = SVGKImage(named: "WorldMap.svg")!
        let width = viewMap.frame.size.width
        let scale = width / mapImage.size.width
        let height = mapImage.size.height * scale
        mapImage.size = CGSize(width: width, height: height)
        let SVGLayeredImageView = SVGKLayeredImageView(svgkImage: mapImage)
        if let imageView = SVGLayeredImageView {
            viewMap.addSubview(imageView)
        }
        
        colorVisitedCounties(on: mapImage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.labelVisitedCountriesNumber.text = "%d/176 countries visited".localized(for: User.sharedInstance.visitedCountriesCodes.count)
        
        User.sharedInstance.visitedCountriesCodes.sort { Countries.codesAndCountries[$0]!.localized() < Countries.codesAndCountries[$1]!.localized() }
    
        self.tableViewVisitedCountries.reloadData()
        colorVisitedCounties(on: mapImage)
    }
    
    func colorVisitedCounties(on map: SVGKImage) {
        let countriesLayers = map.caLayerTree.sublayers?[0].sublayers as! [CAShapeLayer]
        let visitedCountriesLayers = countriesLayers.filter { User.sharedInstance.visitedCountriesCodes.contains($0.name!) }
        
        for layer in visitedCountriesLayers {
            let color = UIColor.blue
            layer.fillColor = color.cgColor
        }
    }
    
    // MARK: - prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController {
            if let controller = navController.viewControllers[0] as? CountriesViewController {
                controller.selectedCountriesCodes = User.sharedInstance.visitedCountriesCodes
            }
        }
    }
    
    // MARK: - tableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return User.sharedInstance.visitedRegions().count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let visitedCountriesInSection = User.sharedInstance.visitedCountriesCodes.filter { User.sharedInstance.visitedRegions()[section].countriesCodes.contains($0) }
        return visitedCountriesInSection.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableViewVisitedCountries.dequeueReusableCell(withIdentifier: "VisitedRegionHeaderCell") as! VisitedRegionHeaderCell
        header.labelRegionName.text = User.sharedInstance.visitedRegions()[section].name
        header.labelVisitedCountriesNumber.text = "\(tableViewVisitedCountries.numberOfRows(inSection: section))/\(User.sharedInstance.visitedRegions()[section].countriesCodes.count)"
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewVisitedCountries.dequeueReusableCell(withIdentifier: "VisitedCountryItemCell") as! VisitedCountryItemCell
        
        let visitedCountriesInSection = User.sharedInstance.visitedCountriesCodes.filter { User.sharedInstance.visitedRegions()[indexPath.section].countriesCodes.contains($0) }
        cell.labelCountryName.text = Countries.codesAndCountries[visitedCountriesInSection[indexPath.row]]?.localized()
        cell.selectionStyle = .none
        
        return cell
    }
    
    // MARK: - scrollViewDelegate
    override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return viewMap
    }
    
    override func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        self.scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0)
    }

}


