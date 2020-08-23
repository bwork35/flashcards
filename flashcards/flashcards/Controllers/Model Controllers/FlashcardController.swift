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
    
            completion(.success(flashcard))
        }
    }
    
    //Read(Fetch)
    func fetchFlashcards(for flashpile: Flashpile, completion: @escaping (Result<[Flashcard]?, FlashError>) -> Void) {
        
        let pileReference = flashpile.recordID
        
        let predicate = NSPredicate(format: "%K == %@", CardStrings.pileReferenceKey, pileReference)
        
        let query = CKQuery(recordType: CardStrings.recordTypeKey, predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 100
        
        var flashRecords = [CKRecord]()
        
        operation.recordFetchedBlock = { record in
            flashRecords.append(record)
        }
        
        operation.queryCompletionBlock = { (cursor: CKQueryOperation.Cursor?, error) -> Void in
            if let error = error {
                print("errrror :(")
                completion(.failure(.ckError(error)))
            }
            if let cursor = cursor {
                let nextOperation = CKQueryOperation(cursor: cursor)
                nextOperation.recordFetchedBlock = { record in
                    flashRecords.append(record)
                }
                nextOperation.queryCompletionBlock = operation.queryCompletionBlock
                nextOperation.resultsLimit = operation.resultsLimit
                self.privateDB.add(nextOperation)
            }
            else {
                let fetchedFlashcards = flashRecords.compactMap { Flashcard(ckRecord: $0) }
                let sortedFlashcards = fetchedFlashcards.sorted(by: { $0.timestamp < $1.timestamp })
                flashpile.flashcards = sortedFlashcards
                completion(.success(sortedFlashcards))
            }
        }
        privateDB.add(operation)
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
        
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = {(_, recordIDs, error) in
            if let error = error {
                print("There was an error deleting the flashcard -- \(error) -- \(error.localizedDescription)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let recordIDs = recordIDs else { return completion(.failure(.couldNotUnwrap))}
            
            if recordIDs.count > 0 {
                print("Successfully deleted flashcard from CloudKit")
                completion(.success(true))
            } else {
                return completion(.failure(.unableToDeleteRecord))
            }
        }
        privateDB.add(operation)
    }
} //End of class
