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
    @IBOutlet weak var flashCoverImageView: UIImageView!
    @IBOutlet weak var deleteButtonBackgroundView: UIVisualEffectView!
    @IBOutlet weak var flashpileNameLabel: UILabel!
    
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
    
    //MARK: - Lifecycles
    override func layoutSubviews() {
        super.layoutSubviews()
        flashCoverImageView.layer.cornerRadius = flashCoverImageView.bounds.width / 8.0
        flashCoverImageView.clipsToBounds = true
        
        self.contentView.layer.cornerRadius = 15.0
        self.contentView.layer.borderWidth = 5.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    //MARK: - Actions
    @IBAction func deleteButtonTapped(_ sender: Any) {
        delegate?.delete(cell: self)
    }
    
    //MARK: - Methods
    func updateViews() {
        guard let flashpile = flashpile else {return}
        flashpileNameLabel.text = flashpile.subject
    }
    
} //End of class
