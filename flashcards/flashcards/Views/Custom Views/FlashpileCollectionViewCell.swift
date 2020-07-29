//
//  FlashpileCollectionViewCell.swift
//  flashcards
//
//  Created by Bryan Workman on 7/18/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import UIKit

protocol FlashpileCellDelegate: AnyObject {
    func delete(cell: FlashpileCollectionViewCell)
}

class FlashpileCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Outlets
    @IBOutlet weak var deleteButtonBackgroundView: UIVisualEffectView!
    @IBOutlet weak var flashpileCoverLabel: UILabel!
    @IBOutlet weak var flashpileNameLabel: UILabel!
    @IBOutlet weak var flashpileCoverImageView: UIImageView!
    
    //MARK: - Properties
    weak var delegate: FlashpileCellDelegate?
    
    var flashpile: Flashpile? {
        didSet {
            updateViews()
            deleteButtonBackgroundView.layer.cornerRadius = deleteButtonBackgroundView.bounds.width / 2.0
            deleteButtonBackgroundView.layer.masksToBounds = true
            deleteButtonBackgroundView.isHidden = !isEditing
        }
    }
    var isEditing: Bool = false {
        didSet {
            deleteButtonBackgroundView.isHidden = !isEditing
        }
    }
    
    //MARK: - Actions
    @IBAction func deleteButtonTapped(_ sender: Any) {
        delegate?.delete(cell: self)
    }
    
    //MARK: - Methods
    func updateViews() {
        guard let flashpile = flashpile else {return}
        flashpileNameLabel.text = flashpile.subject
        if flashpile.flashcards.count != 0 {
            guard let flashcard = flashpile.flashcards.first else {return}
            if flashcard.front is String {
                flashpileCoverLabel.isHidden = false
                flashpileCoverImageView.isHidden = true
                
                let coverTitle = flashcard.front as? String
                flashpileCoverLabel.text = coverTitle
            } else if flashcard.front is UIImage {
                flashpileCoverLabel.isHidden = true
                flashpileCoverImageView.isHidden = false
                
                let coverImage = flashcard.front as? UIImage
                flashpileCoverImageView.image = coverImage
            } else {
                flashpileCoverLabel.isHidden = true
                flashpileCoverImageView.isHidden = true
            }
        } else {
            flashpileCoverLabel.isHidden = true
            flashpileCoverImageView.isHidden = true
            //flashpileCoverLabel.text = ""
        }
        
    }
    
} //End of class
