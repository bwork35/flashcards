//
//  FlashLabel.swift
//  flashcards
//
//  Created by Bryan Workman on 8/1/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import UIKit

class FlashLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textColor = .red
        self.font = UIFont.boldSystemFont(ofSize: 38.0)
        
        let wSize = self.traitCollection.horizontalSizeClass
        let hSize = self.traitCollection.verticalSizeClass

        if wSize == UIUserInterfaceSizeClass.compact && hSize == UIUserInterfaceSizeClass.regular {
            self.font = UIFont.boldSystemFont(ofSize: 27.0)
        }
    
        let strokeTextAttributes = [
            NSAttributedString.Key.strokeColor : UIColor.titleRed,
            NSAttributedString.Key.strokeWidth : -3.0
            ] as [NSAttributedString.Key : Any]
        
        self.attributedText = NSMutableAttributedString(string: self.text!, attributes: strokeTextAttributes)
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 0.25
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.masksToBounds = false
    }
} //End of class

class TextLabel: FlashLabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.font = UIFont.boldSystemFont(ofSize: 32.0)
        
        let wSize = self.traitCollection.horizontalSizeClass
        let hSize = self.traitCollection.verticalSizeClass
        
        if wSize == UIUserInterfaceSizeClass.compact && hSize == UIUserInterfaceSizeClass.regular {
            self.font = UIFont.boldSystemFont(ofSize: 25.0)
        }
    }
} //End of class

class QuizLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 0.25
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.masksToBounds = false
    }
} //End of class

