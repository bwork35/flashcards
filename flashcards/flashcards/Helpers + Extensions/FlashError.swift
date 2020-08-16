//
//  FlashError.swift
//  flashcards
//
//  Created by Bryan Workman on 7/26/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import Foundation

enum FlashError: LocalizedError {
    case ckError(Error)
    case couldNotUnwrap
    case unableToDeleteRecord
    
    var errorDescription: String? {
        switch self {
        case .ckError(let error):
            return "There was an error: \(error) -- \(error.localizedDescription)"
        case .couldNotUnwrap:
            return "There was an error unwrapping the flashfile."
        case .unableToDeleteRecord:
            return "There was an error deleting a record from CloudKit."
        }
    }
} //End of enum
