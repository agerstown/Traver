//
//  MyTipsController.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/25/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

protocol TipsDelegate {
    func tipCreated(country: Codes.Country)
}

class MyTipsController: UIViewController {
    
    @IBOutlet weak var tableViewTips: UITableView!
    
    let activityIndicatorInitialLoading = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var selectedTip: Tip? 
    
    var tipsDelegate: TipsDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My tips".localized()
        
        tableViewTips.dataSource = self
        tableViewTips.delegate = self
        
        tableViewTips.estimatedRowHeight = 160
        tableViewTips.rowHeight = UITableViewAutomaticDimension
        
        tableViewTips.tableFooterView = UIView()
        
        reloadTipsTable()
    }
    
    // MARK: Tips update
    func reloadTipsTable() {
        if User.shared.tips != nil {
            tableViewTips.reloadData()
        } else {
            startSpinning()
            TipApiManager.shared.getUserTips() { tips in
                User.shared.tips = tips
                self.stopSpinning()
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
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController {
            if let controller = navController.viewControllers[0] as? TipController {
                controller.tip = selectedTip
                controller.tipDelegate = self
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension MyTipsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return User.shared.tips?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewTips.dequeue(MyTipCell.self)
        if let tip = User.shared.tips?[indexPath.row] {
            configureCell(cell: cell, tip: tip)
        }
        return cell
    }
    
    func configureCell(cell: MyTipCell, tip: Tip) {
        cell.labelTipTitle.text = tip.title
        cell.labelTipText.text = tip.text
        cell.labelCreationDate.text = tip.dateString
        cell.labelCountry.text = tip.country.name
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if let tip = User.shared.tips?[indexPath.row] {
                TipApiManager.shared.deleteTip(id: tip.id) {
                    User.shared.tips?.remove(at: indexPath.row)
                    self.tableViewTips.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
}

// MARK: - UITableViewDelegate
extension MyTipsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewTips.deselectRow(at: indexPath, animated: true)
        selectedTip = User.shared.tips?[indexPath.row]
        performSegue(withIdentifier: "segueToTipController", sender: nil)
    }
}

// MARK: - TipDelegate
extension MyTipsController: TipDelegate {
    
    func tipUpdated(tip: Tip) {
        if let row = User.shared.tips?.index(of: tip) {
            let indexPath = IndexPath(row: row, section: 0)
            if let cell = tableViewTips.cellForRow(at: indexPath) as? MyTipCell {
                configureCell(cell: cell, tip: tip)
                tableViewTips.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        selectedTip = nil
    }
    
    func tipCreated(tip: Tip) {
        User.shared.tips?.insert(tip, at: 0)
        tableViewTips.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        tipsDelegate?.tipCreated(country: tip.country)
    }

}
