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

    @IBOutlet weak var imageViewMap: UIImageView!
    @IBOutlet weak var viewUserInfo: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelJob: UILabel!
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var tableViewCountries: UITableView!
    
    override func viewDidLoad() {
        print(SVGKit())
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

