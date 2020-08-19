//
//  ElementController.swift
//  flashcards
//
//  Created by Bryan Workman on 8/8/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import Foundation

struct SStringConstants {
    fileprivate static let baseURLString = "https://periodic-table-api.herokuapp.com"
} //End of struct

class ElementController {
    
    static let shared = ElementController()

    var elements: [Element] = []

    static func fetchElements(completion: @escaping (Result<Bool, ElementError>) -> Void) {
        guard let url = URL(string: SStringConstants.baseURLString) else {return completion(.failure(.invalidURL))}
        print(url)

        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            }

            guard let data = data else {return completion(.failure(.noData))}

            do {
                let topLevelArray = try JSONDecoder().decode([Element].self, from: data)
    
                ElementController.shared.elements = topLevelArray
                print("elements: \(ElementController.shared.elements.count)")
                completion(.success(true))

            } catch {
                return completion(.failure(.thrownError(error)))
            }
        }.resume()
    }
} //End of class
