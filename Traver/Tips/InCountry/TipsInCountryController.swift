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
    
    var friends: Bool?
    
    let activityIndicatorInitialLoading = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var selectedTip: Tip?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = country?.name
        
        tableViewTips.dataSource = self
        tableViewTips.delegate = self
        
        tableViewTips.estimatedRowHeight = 180
        tableViewTips.rowHeight = UITableViewAutomaticDimension
        
        tableViewTips.tableFooterView = UIView()
        
        startSpinning()
        reloadTipsTable() {
            self.stopSpinning()
        }
    }
    
    // MARK: Tips update
    func reloadTipsTable(completion: @escaping () -> Void) {
        if let country = country {
            
            if let friends = friends {
                if friends {
                    TipApiManager.shared.getTipsForCountryFriends(country) { tips in
                        self.tipsLoaded(tips: tips, completion: completion)
                    }
                } else {
                    TipApiManager.shared.getTipsForCountry(country) { tips in
                        self.tipsLoaded(tips: tips, completion: completion)
                    }
                }
            }
        }
    }

    func tipsLoaded(tips: [Tip], completion: @escaping () -> Void) {
        completion()
        self.tips = tips
        tableViewTips.reloadData()
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
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? DetailedTipController {
            controller.tip = selectedTip
            controller.backgroundImage = Bluring.blurBackground(backgroundController: self)
        }
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
        cell.labelCreationDate.text = tip.dateString
    
        TipApiManager.shared.getAuthorPhoto(author: tip.author, putInto: cell.imageViewAuthorPhoto)

        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension TipsInCountryController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewTips.deselectRow(at: indexPath, animated: true)
        selectedTip = tips[indexPath.row]
        performSegue(withIdentifier: "segueToTipController", sender: nil)
    }
}
