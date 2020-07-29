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
}
