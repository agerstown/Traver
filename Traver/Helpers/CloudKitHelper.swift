//
//  CloudKitHelper.swift
//  Traver
//
//  Created by Natalia Nikitina on 3/3/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitHelper {
    
    static let shared = CloudKitHelper()
    
    var defaultContainer: CKContainer?
    
    init() {
        defaultContainer = CKContainer.default()
    }
    
    func login() {
        defaultContainer?.fetchUserRecordID { recordID, _ in
            if let id = recordID?.recordName {
                UserApiManager.shared.getOrCreateUserWithICloud(id: id, name: User.shared.name, location: User.shared.location, photo: User.shared.photo)
            }
        }
    }
    
//    func getUserID(completion: @escaping (_ id: String?) -> Void) {
//        defaultContainer?.fetchUserRecordID { recordID, error in
//            completion(recordID?.recordName)
//        }
//    }
    
}
