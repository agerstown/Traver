//
//  Dictionary+InverseKeysValues.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/24/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

extension Dictionary where Value: Hashable {
    
    func inverseKeysValues() -> Dictionary<Value, Key> {
        var result = Dictionary<Value, Key>()
        for (key, value) in self {
            result[value] = key
        }
        return result
    }
}
