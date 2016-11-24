//
//  CountriesController.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/23/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class CountriesViewController: UITableViewController {
    
    @IBOutlet var tableViewCountries: UITableView!
    var selectedIndexes = [Int]()
    
    // MARK: - Actions
    @IBAction func buttonDoneClicked(_ button: UIBarButtonItem) {
        User.sharedInstance.visitedCountries = Countries.codes.filter(visited)
        self.dismiss(animated: true, completion: nil)
    }

    func visited(_ country: String) -> Bool {
        let index = Countries.codes.index(of: country)
        return selectedIndexes.contains { $0 == index }
    }
    
    @IBAction func buttonCountryItemStateClicked(_ button: UIButton) {
        if let cell = button.superview?.superview as? UITableViewCell {
            if let indexPath = self.tableViewCountries.indexPath(for: cell) {
                var image: UIImage?
                if !self.selectedIndexes.contains(indexPath.row) {
                    image = UIImage(named: "item_checked")
                    self.selectedIndexes.append(indexPath.row)
                } else {
                    image = UIImage(named: "item_unchecked")
                    self.selectedIndexes.removeObject(indexPath.row)
                }
                button.setImage(image, for: .normal)
            }
        }
    }
    
    // MARK: - tabelViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Countries.countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableViewCountries.dequeueReusableCell(withIdentifier: "CountryItemCell") as! CountryItemCell
        cell.labelCountryName.text = Countries.countries[indexPath.row]
        let image = self.selectedIndexes.contains(indexPath.row) ? UIImage(named: "item_checked") : UIImage(named: "item_unchecked")
        cell.buttonItemState.setImage(image, for: .normal)
        cell.selectionStyle = .none
        
        return cell
    }
    
}
