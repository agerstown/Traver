//
//  TipsInCountryController.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/20/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

class TipsInCountryController: UIViewController {
    
    @IBOutlet weak var tableViewTips: UITableView!
    
    var country: Codes.Country?
    
    var tips: [Tip] = []
    
    let activityIndicatorInitialLoading = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    let dateFormatter = DateFormatter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        tableViewTips.dataSource = self
        tableViewTips.delegate = self
        
        tableViewTips.estimatedRowHeight = 180
        tableViewTips.rowHeight = UITableViewAutomaticDimension
        
        startSpinning()
        reloadTipsTable() {
            self.stopSpinning()
        }
    }
    
    // MARK: Tips update
    func reloadTipsTable(completion: @escaping () -> Void) {
        if let country = country {
            TipApiManager.shared.getTipsForCountry(country) { tips in
                completion()
                self.tips = tips
                self.tableViewTips.reloadData()
            }
        }
    }

    
    // MARK: - Spinner for initial tips loading
    func startSpinning() {
        tableViewTips.isHidden = true
        
        activityIndicatorInitialLoading.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
        self.view.addSubview(activityIndicatorInitialLoading)
        activityIndicatorInitialLoading.startAnimating()
    }
    
    func stopSpinning() {
        activityIndicatorInitialLoading.stopAnimating()
        activityIndicatorInitialLoading.removeFromSuperview()
        tableViewTips.isHidden = false
    }
}

// MARK: - UITableViewDataSource
extension TipsInCountryController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewTips.dequeue(TipCell.self)
        let tip = tips[indexPath.row]
        cell.labelTitle.text = tip.title
        cell.labelText.text = tip.text
        cell.labelAuthorName.text = tip.author.name ?? "Anonymous".localized()
        cell.labelCreationDate.text = dateFormatter.string(from: tip.creationDate)
    
        TipApiManager.shared.getAuthorPhoto(author: tip.author, putInto: cell.imageViewAuthorPhoto)

        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension TipsInCountryController: UITableViewDelegate {
    
}
