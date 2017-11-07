//
//  Array+findElement.swift
//  FitnessApp
//
//  Created by Grzegorz Hudziak on 27/02/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit

public extension Array {
    
    /// Find element in array
    ///
    /// For example:
    ///
    ///     let people = ["John", "Mark", "Ezehiel", "Goliat"]
    ///     let person = people.findElement { person in
    ///         return person == "Mark"
    ///     }
    ///
    ///     if person != nil {
    ///         // Person found
    ///     }
    ///
    /// - Parameter match: Function that return true if element is this one which is looking for in particular array.
    ///
    ///
    /// - Returns: restur element of array if match is true
    public func findElement(_ match: (Element) -> Bool) -> Element? {
        for element in self where match(element) {
            return element
        }
        return nil
    }
}
