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
    fileprivate static let frontKey = "FrontString"
    fileprivate static let backKey = "BackString"
    fileprivate static let frontPKBoolKey = "frontIsPKImage"
    fileprivate static let backPKBoolKey = "backIsPKImage"
    fileprivate static let frontAsset = "frontPhotoAsset"
    fileprivate static let backAsset = "backPhotoAsset"
    fileprivate static let timestampKey = "timestamp"
    static let pileReferenceKey = "flashpile"
} //End of struct

class Flashcard {
    var frontString: String?
    var backString: String?
    var frontIsPKImage: Bool
    var backIsPKImage: Bool
    var frontPhoto: UIImage? {
        get {
            guard let frontPhotoData = frontPhotoData else {return nil}
            return UIImage(data: frontPhotoData)
        } set {
            frontPhotoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    var backPhoto: UIImage? {
        get {
            guard let backPhotoData = backPhotoData else {return nil}
            return UIImage(data: backPhotoData)
        } set {
            backPhotoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    var frontPhotoData: Data? = nil
    var backPhotoData: Data? = nil
    var frontPhotoAsset: CKAsset? {
        get {
            let tempDir = NSTemporaryDirectory()
            let tempDirURL = URL(fileURLWithPath: tempDir)
            let fileURL = tempDirURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            do {
                guard let data = frontPhotoData else {return nil}
                try data.write(to: fileURL)
                return CKAsset(fileURL: fileURL)
            } catch {
                print(error)
                return nil
            }
        }
    }
    var backPhotoAsset: CKAsset? {
        get {
            let tempDir = NSTemporaryDirectory()
            let tempDirURL = URL(fileURLWithPath: tempDir)
            let fileURL = tempDirURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            do {
                guard let data = backPhotoData else {return nil}
                try data.write(to: fileURL)
                return CKAsset(fileURL: fileURL)
            } catch {
                print(error)
                return nil
            }
        }
    }
    let timestamp: Date
    let recordID: CKRecord.ID
    var pileReference: CKRecord.Reference?
    
    init (frontString: String?, backString: String?, frontIsPKImage: Bool = false, backIsPKImage: Bool, frontPhoto: UIImage?, backPhoto: UIImage?, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), pileReference: CKRecord.Reference?) {
        self.frontString = frontString
        self.backString = backString
        self.frontIsPKImage = frontIsPKImage
        self.backIsPKImage = backIsPKImage
        self.timestamp = timestamp
        self.recordID = recordID
        self.pileReference = pileReference
        self.frontPhoto = frontPhoto
        self.backPhoto = backPhoto
    }
} //End of class

extension Flashcard {
    convenience init?(ckRecord: CKRecord) {
        guard let frontIsPKImage = ckRecord[CardStrings.frontPKBoolKey] as? Bool,
            let backIsPKImage = ckRecord[CardStrings.backPKBoolKey] as? Bool,
            let timestamp = ckRecord[CardStrings.timestampKey] as? Date else {return nil}
        
        let frontString = ckRecord[CardStrings.frontKey] as? String
        let backString = ckRecord[CardStrings.backKey] as? String
        
        
        let pileReference = ckRecord[CardStrings.pileReferenceKey] as? CKRecord.Reference
        
        var frontPhoto: UIImage?
        
        if let frontAsset = ckRecord[CardStrings.frontAsset] as? CKAsset {
            do {
                guard let url = frontAsset.fileURL else {return nil}
                let data = try Data(contentsOf: url)
                frontPhoto = UIImage(data: data)
            } catch {
                print("Could not transfrom asset to data.")
            }
        }
        
        var backPhoto: UIImage?
        
        if let backAsset = ckRecord[CardStrings.backAsset] as? CKAsset {
            do {
                guard let url = backAsset.fileURL else {return nil}
                let data = try Data(contentsOf: url)
                backPhoto = UIImage(data: data)
            } catch {
                print("Could not transfrom asset to data.")
            }
        }
        
        self.init(frontString: frontString, backString: backString, frontIsPKImage: frontIsPKImage, backIsPKImage: backIsPKImage, frontPhoto: frontPhoto, backPhoto: backPhoto, timestamp: timestamp, recordID: ckRecord.recordID, pileReference: pileReference)
    }
} //End of extension

extension CKRecord {
    convenience init(flashcard: Flashcard) {
        self.init(recordType: CardStrings.recordTypeKey, recordID: flashcard.recordID)
        
        self.setValuesForKeys([
            CardStrings.frontPKBoolKey : flashcard.frontIsPKImage,
            CardStrings.backPKBoolKey : flashcard.backIsPKImage,
            CardStrings.timestampKey : flashcard.timestamp
        ])
        
        if let frontString = flashcard.frontString {
            self.setValue(frontString, forKey: CardStrings.frontKey)
        }
        
        if let backString = flashcard.backString {
            self.setValue(backString, forKey: CardStrings.backKey)
        }
        
        if let frontAsset = flashcard.frontPhotoAsset {
            self.setValue(frontAsset, forKey: CardStrings.frontAsset)
        }
        
        if let backAsset = flashcard.backPhotoAsset {
            self.setValue(backAsset, forKey: CardStrings.backAsset)
        }
        
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
