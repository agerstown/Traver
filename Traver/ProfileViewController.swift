//
//  ProfileViewController.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/21/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation
import SVGKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var viewUserInfo: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelJob: UILabel!
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var tableViewCountries: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewCountries.dataSource = self
        tableViewCountries.delegate = self
        
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
    
}

extension ProfileViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sections[section]
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 176
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableViewCountries.dequeueReusableCell(withIdentifier: "CountryItemCell") as! CountryItemCell
        cell.labelCountryName.text = Countries.countries[indexPath.row]
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if (editingStyle == UITableViewCellEditingStyle.delete) {
//            var mapToDelete: Map?
//            if indexPath.section == 0 {
//                mapToDelete = permanentMaps[indexPath.row]
//            }
//            else {
//                mapToDelete = temporaryMaps[indexPath.row]
//            }
//            User.currentUser?.maps.removeObject(mapToDelete!)
//            mapsList.removeObject(mapToDelete!)
//            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
//        }
//    }

}

extension ProfileViewController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//    }
    
}
