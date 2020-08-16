//
//  MultiplicationTables.swift
//  flashcards
//
//  Created by Bryan Workman on 7/16/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import Foundation

enum MultiplicationTables {
    
    static var prompts = ["2 x 2", "2 x 3", "2 x 4", "2 x 5", "2 x 6", "2 x 7", "2 x 8", "2 x 9", "2 x 10", "2 x 11", "2 x 12", "3 x 3", "3 x 4", "3 x 5", "3 x 6", "3 x 7", "3 x 8", "3 x 9", "3 x 10", "3 x 11", "3 x 12", "4 x 4", "4 x 5", "4 x 6", "4 x 7", "4 x 8", "4 x 9", "4 x 10", "4 x 11", "4 x 12", "5 x 5", "5 x 6", "5 x 7", "5 x 8", "5 x 9", "5 x 10", "5 x 11", "5 x 12", "6 x 6", "6 x 7", "6 x 8", "6 x 9", "6 x 10", "6 x 11", "6 x 12", "7 x 7", "7 x 8", "7 x 9", "7 x 10", "7 x 11", "7 x 12", "8 x 8", "8 x 9", "8 x 10", "8 x 11", "8 x 12", "9 x 9", "9 x 10", "9 x 11", "9 x 12",  "10 x 10", "10 x 11", "10 x 12", "11 x 11", "11 x 12", "12 x 12"]
    
    static var answers = ["4", "6", "8", "10", "12", "14", "16", "18", "20", "22", "24", "9", "12", "15", "18", "21", "24", "27", "30", "33", "36", "16", "20", "24", "28", "32", "36", "40", "44", "48", "25", "30", "35", "40", "45", "50", "55", "60", "36", "42", "48", "54", "60", "66", "72", "49", "56", "63", "70", "77", "84", "64", "72", "80", "88", "96", "81", "90", "99", "108","100", "110", "120", "121", "132", "144"]
    
} //End of enum

//func createMultTables(){
//     createFlashpile(subject: "Multiplication") { (result) in
//         DispatchQueue.main.async {
//             switch result {
//             case .success(_):
//                 print("")
//             case .failure(let error):
//                 print("There was an error creating new flashpile -- \(error) -- \(error.localizedDescription)")
//             }
//         }
//     }
//
//     guard let lastFlash = self.totalFlashpiles.last else {return}
//
//     for prompt in MultiplicationTables.prompts {
//         guard let index = MultiplicationTables.prompts.firstIndex(of: prompt) else {return}
//         let answer = MultiplicationTables.answers[index]
//         FlashcardController.shared.createFlashcard(frontString: prompt, backString: answer, frontIsPKImage: false, backIsPKImage: false, frontPhoto: nil, backPhoto: nil, flashpile: lastFlash) { (result) in
//             switch result {
//             case .success(_):
//                 print("yes")
//             case .failure(let error):
//                 print("There was an error creating a new flashcard -- \(error) -- \(error.localizedDescription)")
//             }
//         }
//     }
// }
