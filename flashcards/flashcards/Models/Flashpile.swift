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
    fileprivate static let timestampKey = "timestamp"
}

class Flashpile {
    var subject: String
    var flashcards: [Flashcard]
    var timestamp: Date
    
    let recordID: CKRecord.ID
    
    init (subject: String, flashcards: [Flashcard] = [], timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.subject = subject
        self.flashcards = flashcards
        self.timestamp = timestamp
        self.recordID = recordID
    }
} //End of class

extension Flashpile {
    convenience init?(ckRecord: CKRecord) {
        guard let subject = ckRecord[FlashStrings.subjectKey] as? String,
            let timestamp = ckRecord[FlashStrings.timestampKey] as? Date else {return nil}
        
        self.init(subject: subject, flashcards: [], timestamp: timestamp, recordID: ckRecord.recordID)
    }
} //End of Extension

extension CKRecord {
    convenience init(flashpile: Flashpile) {
        self.init(recordType: FlashStrings.recordTypeKey, recordID: flashpile.recordID)
        
        self.setValuesForKeys([
            FlashStrings.subjectKey : flashpile.subject,
            FlashStrings.timestampKey : flashpile.timestamp
        ])
    }
} //End of extension

extension Flashpile: Equatable {
    static func == (lhs: Flashpile, rhs: Flashpile) -> Bool {
        return lhs.recordID == rhs.recordID
    }
} //End of Extension
