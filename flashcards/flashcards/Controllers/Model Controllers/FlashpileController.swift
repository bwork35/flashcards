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
    
    //MARK: - CRUD
    
    //Create
    func createFlashpile(subject: String, completion: @escaping (Result<Flashpile, FlashError>) -> Void) {
        
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
            completion(.success(savedFlashpile))
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
            
            print("Successfully updated the flashpile")
            completion(.success(updatedFlashpile))
        }
        privateDB.add(operation)
    }

    //Delete
    func deleteFlashpile(flashpile: Flashpile, completion: @escaping (Result<Bool, FlashError>) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [flashpile.recordID])

        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = {(_, recordIDs, error) in
            if let error = error {
                print("There was an error deleting the flashpile -- \(error) -- \(error.localizedDescription)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let recordIDs = recordIDs else { return completion(.failure(.couldNotUnwrap))}
            
            if recordIDs.count > 0 {
                print("Successfully deleted flashpile from CloudKit.")
                completion(.success(true))
            } else {
                return completion(.failure(.unableToDeleteRecord))
            }
        }
        privateDB.add(operation)
    }
    
    //MARK: - First Launch
    func createMultPile(completion: @escaping (Result<Flashpile, Error>) -> Void) {
        FlashpileController.shared.createFlashpile(subject: "Multiplication") { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let flashpile):
                    completion(.success(flashpile))
                case .failure(_):
                    print("Failed to create Multiplication Flashpile.")
                }
            }
        }
    }
    
    func createMultCards(flashpile: Flashpile, completion: @escaping () -> Void) {
        let group = DispatchGroup()
        for prompt in MultiplicationTables.prompts {
            group.enter()
            guard let index = MultiplicationTables.prompts.firstIndex(of: prompt) else {return}
            let answer = MultiplicationTables.answers[index]
            FlashcardController.shared.createFlashcard(frontString: prompt, backString: answer, frontIsPKImage: false, backIsPKImage: false, frontPhoto: nil, backPhoto: nil, flashpile: flashpile) { (result) in
                switch result {
                case .success(let flashcard):
                    flashpile.flashcards.append(flashcard)
                case .failure(_):
                    print("error")
                }
                group.leave()
            }
        }
        group.notify(queue: .main){
            return completion()
        }
    }
    
    func createElementPile(completion: @escaping (Result<Flashpile, Error>) -> Void) {
        FlashpileController.shared.createFlashpile(subject: "Periodic Table") { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let flashpile):
                    completion(.success(flashpile))
                case .failure(_):
                    print("Error creating Periodic Table Flashpile")
                }
            }
        }
    }
    
    func createElementCards(flashpile: Flashpile, completion: @escaping () -> Void) {
        let group = DispatchGroup()
        for symbol in PeriodicTable.symbol {
            group.enter()
            guard let index = PeriodicTable.symbol.firstIndex(of: symbol) else {return}
            let numAndName = PeriodicTable.numberAndName[index]
            FlashcardController.shared.createFlashcard(frontString: symbol, backString: numAndName, frontIsPKImage: false, backIsPKImage: false, frontPhoto: nil, backPhoto: nil, flashpile: flashpile) { (result) in
                switch result {
                case .success(let flashcard):
                    flashpile.flashcards.append(flashcard)
                case .failure(_):
                    print("error")
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion()
        }
    }

    func createCapitalPile(completion: @escaping (Result<Flashpile, Error>) -> Void) {
        FlashpileController.shared.createFlashpile(subject: "States and Capitals") { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let flashpile):
                    completion(.success(flashpile))
                case .failure(_):
                    print("Error creating State Capitals flashpile.")
                }
            }
        }
    }

    func createCapitalCards(flashpile: Flashpile, completion: @escaping () -> Void) {
        let group = DispatchGroup()
        for state in StatesAndCapitals.states {
            group.enter()
            guard let index = StatesAndCapitals.states.firstIndex(of: state) else {return}
            let capital = StatesAndCapitals.capitals[index]
            FlashcardController.shared.createFlashcard(frontString: state, backString: capital, frontIsPKImage: false, backIsPKImage: false, frontPhoto: nil, backPhoto: nil, flashpile: flashpile) { (result) in
                switch result {
                case .success(let flashcard):
                    flashpile.flashcards.append(flashcard)
                case .failure(_):
                    print("error")
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            return completion()
        }
    }
} // End of class
