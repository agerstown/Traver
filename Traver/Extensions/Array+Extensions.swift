//
//  Array+Extensions.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/23/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func removeObject(_ object: Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
}

extension Array {
    mutating func append(_ element: Element, using condition: (Element, Element) -> Bool) {
        var index: Int?
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if condition(self[mid], element) {
                lo = mid + 1
            } else if condition(element, self[mid]) {
                hi = mid - 1
            } else {
                index =  mid
            }
        }
        if index == nil { index = lo }
        self.insert(element, at: index!)
    }
}
