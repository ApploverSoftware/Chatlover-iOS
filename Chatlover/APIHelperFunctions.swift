//
//  APIHelperFunctions.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 17/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit

class APIError: Error {
    var localizedDescription: String
    
    init(localizedDescription: String = "") {
        self.localizedDescription = localizedDescription
    }
}

enum Result<T> {
    case success(T)
    case failure(Error)
}

/// Used when no result is needed return from called function
class EmptySuccess {
    
}
