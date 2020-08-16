//
//  FlashcardController.swift
//  flashcards
//
//  Created by Bryan Workman on 7/16/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import Foundation
import CloudKit
import UIKit.UIImage

class FlashcardController {
    
    //MARK: - Properties
    static let shared = FlashcardController()
    
    var totalFlashcards: [Flashcard] = []
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    //MARK: - CRUD Methods
    
    //Create
    func createFlashcard(frontString: String?, backString: String?, frontIsPKImage: Bool, backIsPKImage: Bool, frontPhoto: UIImage?, backPhoto: UIImage?, flashpile: Flashpile, completion: @escaping (Result<Flashcard, FlashError>) -> Void) {
        
        let pileReference = CKRecord.Reference(recordID: flashpile.recordID, action: .deleteSelf)
        
        let newFlashcard = Flashcard(frontString: frontString, backString: backString, frontIsPKImage: frontIsPKImage, backIsPKImage: backIsPKImage, frontPhoto: frontPhoto, backPhoto: backPhoto, pileReference: pileReference)
        
        let cardRecord = CKRecord(flashcard: newFlashcard)
        
        privateDB.save(cardRecord) { (record, error) in
            if let error = error {
                print("There was an error creating a flashcard -- \(error) -- \(error.localizedDescription)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record,
                let flashcard = Flashcard(ckRecord: record) else {return completion(.failure(.couldNotUnwrap))}
            
            print("Flashcard Successfully Saved")
            flashpile.flashcards.append(flashcard)
            completion(.success(flashcard))
        }
    }
    
    //Read(Fetch)
    func fetchFlashcards(for flashpile: Flashpile, completion: @escaping (Result<[Flashcard]?, FlashError>) -> Void) {
        
        let pileReference = flashpile.recordID
        
        let predicate = NSPredicate(format: "%K == %@", CardStrings.pileReferenceKey, pileReference)
        
        let flashcardIDs = flashpile.flashcards.compactMap({$0.recordID})
        
        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", flashcardIDs)
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let query = CKQuery(recordType: CardStrings.recordTypeKey, predicate: compoundPredicate)
        
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("There was an error fetching flashcards -- \(error) -- \(error.localizedDescription)")
                completion(.failure(.ckError(error)))
            }
            
            guard let records = records else {return completion(.failure(.couldNotUnwrap))}
            
            print("Fetched Flashcard Records Successfully")
            
            let fetchedFlashcards = records.compactMap { Flashcard(ckRecord: $0) }
            let sortedFlashcards = fetchedFlashcards.sorted(by: { $0.timestamp < $1.timestamp })
            
            flashpile.flashcards.append(contentsOf: sortedFlashcards)
            
            completion(.success(sortedFlashcards))
        }
    }
    
    //Update
    func updateFlashcard(flashcard: Flashcard, frontString: String?, backString: String?, frontIsPKImage: Bool, backIsPKImage: Bool, frontPhoto: UIImage?, backPhoto: UIImage?, completion: @escaping (Result<Flashcard, FlashError>) -> Void) {
        
        flashcard.frontString = frontString
        flashcard.backString = backString
        flashcard.frontPhoto = frontPhoto
        flashcard.backPhoto = backPhoto
        flashcard.frontIsPKImage = frontIsPKImage
        flashcard.backIsPKImage = backIsPKImage
        
        let record = CKRecord(flashcard: flashcard)
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = {(records, _, error) in
            if let error = error {
                print("There was an error updating the flashcard -- \(error) -- \(error.localizedDescription)")
                return completion(.failure(.ckError(error)))
            }
            guard let record = records?.first,
                let updatedFlashcard = Flashcard(ckRecord: record) else {return completion(.failure(.couldNotUnwrap))}
            
            print("Successfully updated the flashcard")
            completion(.success(updatedFlashcard))
        }
        privateDB.add(operation)
    }
    
    //Delete
    func deleteFlashcard(flashcard: Flashcard, completion: @escaping (Result<Bool, FlashError>) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [flashcard.recordID])
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = {(records, _, error) in
            if let error = error {
                print("There was an error deleting the flashcard -- \(error) -- \(error.localizedDescription)")
                return completion(.failure(.ckError(error)))
            }
            
            if records?.count == 0 {
                print("Successfully deleted flashcard from CloudKit")
                completion(.success(true))
            } else {
                return completion(.failure(.unableToDeleteRecord))
            }
        }
        privateDB.add(operation)
    }
    
    
    
    
    
    //Create
//    func createTempFlashcard(front: Any, back: Any) {
//        //let newFlashcard = Flashcard(front: front, back: back)
//        let newFlashcard = Flashcard(front: front, back: back, pileReference: <#T##CKRecord.Reference?#>)
//        totalFlashcards.append(newFlashcard)
//    }
//
//    //Update
//    func updateFlashcard(flashcardToUpdate: Flashcard, front: Any, back: Any) {
//        flashcardToUpdate.front = front
//        flashcardToUpdate.back = back
//    }
//
//    //Delete
//    func deleteFlashcard(flashcardToDelete: Flashcard) {
//        if let index = totalFlashcards.firstIndex(of: flashcardToDelete){
//            totalFlashcards.remove(at: index)
//        }
//    }
    
} //End of class
