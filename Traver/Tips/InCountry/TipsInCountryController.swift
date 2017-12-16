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
    @IBOutlet weak var activityIndicatorBottom: UIActivityIndicatorView!
    
    var country: Codes.Country?
    
    var tips: [Tip] = []
    
    var friends: Bool?
    
    let activityIndicatorInitialLoading = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var selectedTip: Tip?
    
    var numberOfTips: Int?
    
    var loading = false
    var lastLoadedPageNumber = 0
    let tipsNumberOnPage = 10
    var hasNextPage: Bool {
        if let numberOfTips = numberOfTips {
            return numberOfTips > (lastLoadedPageNumber + 1) * tipsNumberOnPage
        } else {
            return false
        }
    }
    
    let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = country?.name
        
        tableViewTips.dataSource = self
        tableViewTips.delegate = self
        
        tableViewTips.estimatedRowHeight = 180
        tableViewTips.rowHeight = UITableViewAutomaticDimension
        
        refreshControl.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        tableViewTips.refreshControl = refreshControl
        
        activityIndicatorBottom.isHidden = true
        
        startSpinning()
        reloadTipsTable() {
            self.stopSpinning()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(userBlocked), name: UserApiManager.shared.UserBlockedNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Tips update
    func reloadTipsTable(completion: @escaping () -> Void) {
        if let country = country {
            if let friends = friends {
                if friends {
                    TipApiManager.shared.getTipsForCountryFriendsPage(country, page: lastLoadedPageNumber) { tips in
                        self.updateTips(tips: tips, completion: completion)
                    }
                } else {
                    TipApiManager.shared.getTipsForCountryPage(country, page: lastLoadedPageNumber) { tips in
                        self.updateTips(tips: tips, completion: completion)
                    }
                }
            }
        }
    }

    func updateTips(tips: [Tip], completion: @escaping () -> Void) {
        completion()
        self.tips = tips
        tableViewTips.reloadData()
    }
    
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        lastLoadedPageNumber = 0
        reloadTipsTable() {
            refreshControl.endRefreshing()
        }
    }
    
    @objc func userBlocked() {
        lastLoadedPageNumber = 0
        startSpinning()
        reloadTipsTable() {
            self.stopSpinning()
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

        loadMoreCoursesIfNecessary(row: indexPath.row)
        
        return cell
    }
    
    func loadMoreCoursesIfNecessary(row: Int) {
        if hasNextPage {
            if loading == false {
                if row == tips.count - 3 {
                    activityIndicatorBottom.isHidden = false
                    activityIndicatorBottom.startAnimating()
                    
                    loading = true
                    
                    if let country = country {
                        if let friends = friends {
                            if friends {
                               TipApiManager.shared.getTipsForCountryFriendsPage(country,
                                                                                 page: lastLoadedPageNumber + 1) { tips in
                                    self.addNewTips(tips: tips)
                                }
                            } else {
                                TipApiManager.shared.getTipsForCountryPage(country, page: lastLoadedPageNumber + 1) { tips in
                                    self.addNewTips(tips: tips)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addNewTips(tips: [Tip]) {
        activityIndicatorBottom.stopAnimating()
        activityIndicatorBottom.isHidden = true
        
        lastLoadedPageNumber += 1
        self.tips.append(contentsOf: tips)
        tableViewTips.reloadData()
        
        loading = false
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
