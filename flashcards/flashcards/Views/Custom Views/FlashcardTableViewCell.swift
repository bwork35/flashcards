//
//  FlashcardTableViewCell.swift
//  flashcards
//
//  Created by Bryan Workman on 7/24/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import UIKit

class FlashcardTableViewCell: UITableViewCell {
    
    //MARK: - Outlets
    @IBOutlet weak var frontLabel: UILabel!
    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var backImageView: UIImageView!
    
    //MARK: - Properties
    var flashcard: Flashcard? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - Helper Methods
    func updateViews() {
        guard let flashcard = flashcard else {return}
        
        if let frontString = flashcard.frontString {
            frontLabel.isHidden = false
            frontImageView.isHidden = true
            frontLabel.text = frontString
        } else if let frontPhoto = flashcard.frontPhoto {
            frontLabel.isHidden = true
            frontImageView.isHidden = false
            frontImageView.image = frontPhoto
        } else {
            frontLabel.isHidden = true
            frontImageView.isHidden = true
        }
        
        if let backString = flashcard.backString {
            backLabel.isHidden = false
            backImageView.isHidden = true
            backLabel.text = backString
        } else if let backPhoto = flashcard.backPhoto {
            backLabel.isHidden = true
            backImageView.isHidden = false
            backImageView.image = backPhoto
        } else {
            backLabel.isHidden = true
            backImageView.isHidden = true
        }
    }

} //End of class
