//
//  ProfileViewController.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/21/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class ProfileViewController: UITableViewController {

    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var viewUserInfo: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelJob: UILabel!
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet var tableViewVisitedCountries: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting up the map and it's size
        let mapImage = SVGKImage(named: "WorldMap.svg")!
        let width = viewMap.frame.size.width
        let scale = width / mapImage.size.width
        let height = mapImage.size.height * scale
        mapImage.size = CGSize(width: width, height: height)
        let SVGLayeredImageView = SVGKLayeredImageView(svgkImage: mapImage)
        if let imageView = SVGLayeredImageView {
            viewMap.addSubview(imageView)
        }
        
//        let mainLayer = mapImage.caLayerTree
//        let subLayers = mainLayer?.sublayers
//        if let subLayers = subLayers {
//            for layer in subLayers {
//                print(layer)
//                let subSubs = layer.sublayers
//                if let subSubs = subSubs {
//                    for subSub in subSubs {
//                        print(subSub.name)
//                    }
//                }
//            }
//        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableViewVisitedCountries.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController {
            if let controller = navController.viewControllers[0] as? CountriesViewController {
                controller.selectedIndexes = getVisitedCountriesIndexes()
            }
        }
    }
    
    func getVisitedCountriesIndexes() -> [Int] {
        var indexes = [Int]()
        for (index, country) in Countries.countries.enumerated() {
            if User.sharedInstance.visitedCountries.contains(country) {
                indexes.append(index)
            }
        }
        return indexes
    }
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return sections[section]
    //    }
    
    // MARK: - tableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return User.sharedInstance.visitedCountries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableViewVisitedCountries.dequeueReusableCell(withIdentifier: "VisitedCountryItemCell") as! VisitedCountryItemCell
        cell.labelCountryName.text = User.sharedInstance.visitedCountries[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
    
}
