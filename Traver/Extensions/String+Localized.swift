//
//  String+Localized.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/27/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func localized(for number: Int) -> String {
        return String.localizedStringWithFormat(NSLocalizedString(self, comment: ""), number)
    }
}
