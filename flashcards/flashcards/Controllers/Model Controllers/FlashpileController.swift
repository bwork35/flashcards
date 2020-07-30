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
    
//    init() {
//        let multiplicationTables = createMultTables()
//        totalFlashpiles.append(multiplicationTables)
//
//        let colorTables = createColorTables()
//        totalFlashpiles.append(colorTables)

//        let fruitTables = createFruitTables()
//        totalFlashpiles.append(fruitTables)
//    }
//
//    func createMultTables() -> Flashpile {
//        var multTablesToReturn: [Flashcard] = []
//        for prompt in MultiplicationTables.prompts {
//            guard let index = MultiplicationTables.prompts.firstIndex(of: prompt) else {return Flashpile(subject: "", flashcards: [])}
//            let answer = MultiplicationTables.answers[index]
//            let flashcard = Flashcard(front: prompt, back: answer)
//            multTablesToReturn.append(flashcard)
//        }
//        let flashpileToReturn = Flashpile(subject: "Multiplication", flashcards: multTablesToReturn)
//        return flashpileToReturn
//    }
//
//    func createColorTables() -> Flashpile {
//        var colorTableToReturn: [Flashcard] = []
//
//        let yellowCard = Flashcard(front: "yellow", back: "yellow")
//        let greenCard = Flashcard(front: "green", back: "green")
//        let blueCard = Flashcard(front: "blue", back: "blue")
//        let purpleCard = Flashcard(front: "purple", back: "purple")
//        let redCard = Flashcard(front: "red", back: "red")
//        let orangeCard = Flashcard(front: "orange", back: "orange")
//
//        colorTableToReturn.append(yellowCard)
//        colorTableToReturn.append(greenCard)
//        colorTableToReturn.append(blueCard)
//        colorTableToReturn.append(purpleCard)
//        colorTableToReturn.append(redCard)
//        colorTableToReturn.append(orangeCard)
//
//        let flashpileToReturn = Flashpile(subject: "Color Tables", flashcards: colorTableToReturn)
//        return flashpileToReturn
//    }

//    func createFruitTables() -> Flashpile {
//        var fruitCard: [Flashcard] = []
//
//        let apple = Flashcard(front: UIImage(named: "apple"), back: "apple")
//        let banana = Flashcard(front: UIImage(named: "banana"), back: "banana")
//        let orange = Flashcard(front: UIImage(named: "orange"), back: "orange")
//        let grapes = Flashcard(front: UIImage(named: "grapes"), back: "grapes")
//        let strawberry = Flashcard(front: UIImage(named: "strawberry"), back: "strawberry")
//        let watermelon = Flashcard(front: UIImage(named: "watermelon"), back: "watermelon")
//        let coconut = Flashcard(front: UIImage(named: "coconut"), back: UIImage(named: "coconutWord"))
//        let pineapple = Flashcard(front: UIImage(named: "pineapple"), back: UIImage(named: "pineappleWord"))
//        let cherries = Flashcard(front: UIImage(named: "cherries"), back: UIImage(named: "cherriesWord"))
//
//        fruitCard.append(apple)
//        fruitCard.append(banana)
//        fruitCard.append(orange)
//        fruitCard.append(grapes)
//        fruitCard.append(strawberry)
//        fruitCard.append(watermelon)
//        fruitCard.append(coconut)
//        fruitCard.append(pineapple)
//        fruitCard.append(cherries)
//
//        let flashpileToReturn = Flashpile(subject: "Fruits", flashcards: fruitCard)
//        return flashpileToReturn
//    }
    
    //MARK: - CRUD
    
    //Create
    func createFlashpile(subject: String, completion: @escaping (Result<Bool, FlashError>) -> Void) {
        
        //flashcard: Flashcard on both these ^ v
        let newFlashpile = Flashpile(subject: subject)
        let newFlashRecord = CKRecord(flashpile: newFlashpile)
        
        privateDB.save(newFlashRecord) { (record, error) in
            print("saveFP")
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
    
            self.totalFlashpiles = fetchedFlashpiles
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
