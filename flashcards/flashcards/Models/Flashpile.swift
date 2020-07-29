//
//  Flashpile.swift
//  flashcards
//
//  Created by Bryan Workman on 7/19/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import Foundation
import CloudKit

struct FlashStrings {
    static let recordTypeKey = "Flashpile"
    fileprivate static let subjectKey = "subject"
    fileprivate static let flashcardKey = "flashcards"
}

class Flashpile {
    var subject: String
    var flashcards: [Flashcard]
    
    let recordID: CKRecord.ID
    
    init (subject: String, flashcards: [Flashcard] = [], recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.subject = subject
        self.flashcards = flashcards
        self.recordID = recordID
    }
} //End of class

extension Flashpile {
    convenience init?(ckRecord: CKRecord) {
        guard let subject = ckRecord[FlashStrings.subjectKey] as? String else {return nil}
        
        self.init(subject: subject, flashcards: [], recordID: ckRecord.recordID)
    }
} //End of Extension

extension CKRecord {
    convenience init(flashpile: Flashpile) {
        self.init(recordType: FlashStrings.recordTypeKey, recordID: flashpile.recordID)
        
        self.setValuesForKeys([
            FlashStrings.subjectKey : flashpile.subject
        ])
    }
} //End of extension

extension Flashpile: Equatable {
    static func == (lhs: Flashpile, rhs: Flashpile) -> Bool {
        return lhs.recordID == rhs.recordID
    }
} //End of Extension
