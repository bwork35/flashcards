//
//  Flashcard.swift
//  flashcards
//
//  Created by Bryan Workman on 7/15/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import UIKit
import CloudKit

struct CardStrings {
    static let recordTypeKey = "Flashcard"
    fileprivate static let frontKey = "Front"
    fileprivate static let backKey = "Back"
    static let pileReferenceKey = "flashpile"
}

class Flashcard {
    
    var front: Any
    var back: Any
    
    let recordID: CKRecord.ID
    var pileReference: CKRecord.Reference?
    
    init (front: Any, back: Any, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), pileReference: CKRecord.Reference?) {
        self.front = front
        self.back = back
        self.recordID = recordID
        self.pileReference = pileReference
    }
} //End of class

extension Flashcard {
    convenience init?(ckRecord: CKRecord) {

        guard let front = ckRecord[CardStrings.frontKey] as? Any,
            let back = ckRecord[CardStrings.backKey] as? Any else {return nil}
        
        let pileReference = ckRecord[CardStrings.pileReferenceKey] as? CKRecord.Reference

        self.init(front: front, back: back, recordID: ckRecord.recordID, pileReference: pileReference)
    }
} //End of extension

extension CKRecord {
    convenience init(flashcard: Flashcard) {
        self.init(recordType: CardStrings.recordTypeKey, recordID: flashcard.recordID)

        self.setValuesForKeys([
            CardStrings.frontKey : flashcard.front,
            CardStrings.backKey : flashcard.back
        ])
        
        if let reference = flashcard.pileReference {
            self.setValue(reference, forKey: CardStrings.pileReferenceKey)
        }
    }
} //End of extension

extension Flashcard: Equatable {
    static func == (lhs: Flashcard, rhs: Flashcard) -> Bool {
        lhs.recordID == rhs.recordID
    }
} //End of extension



//extension Flashcard: Equatable {
//    static func == (lhs: Flashcard, rhs: Flashcard) -> Bool {
//
//        var leftFront: String = ""
//        var rightFront: String = ""
//        var leftBack: String = ""
//        var rightBack: String = ""
//
//        var leftImageFront = UIImage()
//        var rightImageFront = UIImage()
//        var leftImageBack = UIImage()
//        var rightImageBack = UIImage()
//
//        if lhs.front is String {
//            guard let front = lhs.front as? String else {return false}
//            leftFront = front
//        } else if lhs.front is UIImage {
//            guard let front = lhs.front as? UIImage else {return false}
//            leftImageFront = front
//        }
//
//        if rhs.front is String {
//            guard let front = rhs.front as? String else {return false}
//            rightFront = front
//        } else if rhs.front is UIImage {
//            guard let front = rhs.front as? UIImage else {return false}
//            rightImageFront = front
//        }
//
//        if lhs.back is String {
//            guard let back = lhs.back as? String else {return false}
//            leftBack = back
//        } else if lhs.back is UIImage {
//            guard let back = lhs.back as? UIImage else {return false}
//            leftImageBack = back
//        }
//
//        if rhs.back is String {
//            guard let back = rhs.back as? String else {return false}
//            rightBack = back
//        } else if rhs.back is UIImage {
//            guard let back = rhs.back as? UIImage else {return false}
//            rightImageBack = back
//        }
//
//        if lhs.front is String && lhs.back is String {
//            return leftFront == rightFront && leftBack == rightBack
//        } else if lhs.front is String && lhs.back is UIImage {
//            return leftFront == rightFront && leftImageBack == rightImageBack
//        } else if lhs.front is UIImage && lhs.back is String {
//            return leftImageFront == rightImageFront && leftBack == rightBack
//        } else if lhs.front is UIImage && lhs.back is UIImage {
//            return leftImageFront == rightImageFront && leftImageBack == rightImageBack
//        } else{
//            return false
//        }
//    }
//} //End of extension
