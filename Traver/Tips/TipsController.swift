//
//  TipsController.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/20/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

class TipsController: UIViewController {
    
    @IBOutlet weak var segmentedControlTipsCategory: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var barButtonAddTip: UIBarButtonItem!
    @IBOutlet weak var tableViewRegions: UITableView!
    
    var regions = Codes.Region.all
    
    let pictures = [UIImage(named: "europe"), UIImage(named: "asia"), UIImage(named: "north-america"),
                    UIImage(named: "south-america"), UIImage(named: "australia"), UIImage(named: "africa")]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewRegions.dataSource = self
        tableViewRegions.delegate = self
    }
    
}

// MARK: - UITableViewDataSource
extension TipsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewRegions.dequeue(TipsRegionCell.self)
        if indexPath.row % 2 == 1 {
            cell.backgroundColor = .yellowTraverColor
        }
        cell.labelRegionName.text = regions[indexPath.row].name
        cell.imageViewRegionPicture.image = pictures[indexPath.row]
        return cell
    }

}

// MARK: - UITableViewDelegate
extension TipsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.view.bounds.height - 44 - searchBar.bounds.height) / CGFloat(regions.count)
    }
}
