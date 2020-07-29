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
        
        if flashcard.front is String {
            frontLabel.isHidden = false
            frontImageView.isHidden = true
            frontLabel.text = flashcard.front as? String
        } else if flashcard.front is UIImage {
            frontLabel.isHidden = true
            frontImageView.isHidden = false
            frontImageView.image = flashcard.front as? UIImage
        } else {
            frontLabel.isHidden = true
            frontImageView.isHidden = true
        }
        
        if flashcard.back is String {
            backLabel.isHidden = false
            backImageView.isHidden = true
            backLabel.text = flashcard.back as? String
        } else if flashcard.back is UIImage {
            backLabel.isHidden = true
            backImageView.isHidden = false
            backImageView.image = flashcard.back as? UIImage
        } else {
            backLabel.isHidden = true
            backImageView.isHidden = true
        }
    }

}
//let front = flashcard.front as? String ?? "Image"
//let back = flashcard.back as? String ?? "Image"
