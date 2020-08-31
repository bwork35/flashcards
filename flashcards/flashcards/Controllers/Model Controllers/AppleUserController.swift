//
//  AppleUserController.swift
//  flashcards
//
//  Created by Bryan Workman on 8/28/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import Foundation
import CloudKit

class AppleUserController {
    
    static let shared = AppleUserController()
    
    func fetchAppleUserReference(completion: @escaping (Result<CKRecord.Reference, FlashError>) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("There was an error fetching the user's apple record id - \(error) - \(error.localizedDescription)")
                return completion(.failure(.ckError(error)))
            }
            
            if let recordID = recordID {
                let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
                completion(.success(reference))
            }
        }
    }
    
} //End of class
