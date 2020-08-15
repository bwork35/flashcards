//
//  FlashpileController.swift
//  flashcards
//
//  Created by Bryan Workman on 7/19/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import UIKit
import CloudKit

class FlashpileController {
    
    //MARK: - Properties
    static let shared = FlashpileController()
    
    var totalFlashpiles: [Flashpile] = []
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    init() {
        //createMultTables()
       

       // let statesTables = createColorTables()
        //totalFlashpiles.append(statesTables)

        //let periodicTables = createFruitTables()
        //totalFlashpiles.append(periodicTables)
    }

    func createMultTables(){
        createFlashpile(subject: "Multiplication") { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("")
                case .failure(let error):
                    print("There was an error creating new flashpile -- \(error) -- \(error.localizedDescription)")
                }
            }
        }
        
        guard let lastFlash = self.totalFlashpiles.last else {return}
        
        for prompt in MultiplicationTables.prompts {
            guard let index = MultiplicationTables.prompts.firstIndex(of: prompt) else {return}
            let answer = MultiplicationTables.answers[index]
            FlashcardController.shared.createFlashcard(frontString: prompt, backString: answer, frontIsPKImage: false, backIsPKImage: false, frontPhoto: nil, backPhoto: nil, flashpile: lastFlash) { (result) in
                switch result {
                case .success(_):
                    print("yes")
                case .failure(let error):
                    print("There was an error creating a new flashcard -- \(error) -- \(error.localizedDescription)")
                }
            }
        }
    }


    
    //MARK: - CRUD
    
    //Create
    func createFlashpile(subject: String, completion: @escaping (Result<Bool, FlashError>) -> Void) {
        
        let newFlashpile = Flashpile(subject: subject)
        let newFlashRecord = CKRecord(flashpile: newFlashpile)
        
        privateDB.save(newFlashRecord) { (record, error) in
            if let error = error {
                print("There was an error saving the flashpile -- \(error) -- \(error.localizedDescription)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record,
                let savedFlashpile = Flashpile(ckRecord: record) else {return completion(.failure(.couldNotUnwrap))}
            
            self.totalFlashpiles.append(savedFlashpile)
            completion(.success(true))
        }
    }
    
    //Read(Fetch)
    func fetchAllFlashpiles(completion: @escaping (Result<Bool, FlashError>) -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: FlashStrings.recordTypeKey, predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("There was an error fetching flashpile -- \(error) -- \(error.localizedDescription)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let records = records else {return completion(.failure(.couldNotUnwrap))}
            
            let fetchedFlashpiles: [Flashpile] = records.compactMap { Flashpile(ckRecord: $0) }
            let sortedFlashpiles = fetchedFlashpiles.sorted(by: { $0.timestamp > $1.timestamp })
    
            self.totalFlashpiles = sortedFlashpiles
            completion(.success(true))
        }
    }
    
    //Update
    func updateFlashpile(flashpile: Flashpile, completion: @escaping (Result<Flashpile, FlashError>) -> Void) {
        
        let record = CKRecord(flashpile: flashpile)
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = {(records, _, error) in
            if let error = error {
                print("There was an error updating the flashpile -- \(error) -- \(error.localizedDescription)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = records?.first,
                let updatedFlashpile = Flashpile(ckRecord: record) else {return completion(.failure(.couldNotUnwrap))}
            
            print("Successfully updated the flashpile with ID: \(updatedFlashpile.recordID)")
            completion(.success(updatedFlashpile))
        }
        privateDB.add(operation)
    }

    //Delete
    func deleteFlashpile(flashpile: Flashpile, completion: @escaping (Result<Bool, FlashError>) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [flashpile.recordID])
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = {(records, _, error) in
            if let error = error {
                print("There was an error deleting the flashpile -- \(error) -- \(error.localizedDescription)")
                return completion(.failure(.ckError(error)))
            }
            
            if records?.count == 0 {
                print("Successfully deleted flashpile from CloudKit.")
                completion(.success(true))
            } else {
                return completion(.failure(.unableToDeleteRecord))
            }
        }
        privateDB.add(operation)
    }
    
    
    
    //Create
//    func createFlashpile(subject: String, flashcards: [Flashcard]) {
//        let newFlashpile = Flashpile(subject: subject, flashcards: flashcards)
//        totalFlashpiles.append(newFlashpile)
//    }
    
//    //Update
//    func updateFlashpile(flashpileToUpdate: Flashpile, subject: String, flashcards: [Flashcard]) {
//        flashpileToUpdate.subject = subject
//        flashpileToUpdate.flashcards = flashcards
//    }
//
//    //Delete
//    func deleteFlashpile(flashpileToDelete: Flashpile) {
//        if let index = totalFlashpiles.firstIndex(of: flashpileToDelete) {
//            totalFlashpiles.remove(at: index)
//        }
//    }
    
} // End of class
