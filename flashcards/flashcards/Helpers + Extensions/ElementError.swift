//
//  ElementError.swift
//  flashcards
//
//  Created by Bryan Workman on 8/8/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import Foundation

enum ElementError: LocalizedError {
    case invalidURL
    case thrownError(Error)
    case noData
    case unableToDecode
} 
