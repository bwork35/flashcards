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
        self.textColor = .titleRed
        self.font = UIFont.boldSystemFont(ofSize: 27.0)
        
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
        //self.textColor = .titleRed
        self.font = UIFont.boldSystemFont(ofSize: 25.0)
    }
} //End of class

class QuizLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.textColor = .titleRed
        self.font = UIFont(name: "Gill Sans", size: 22.0)
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 0.25
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.masksToBounds = false
    }
} //End of class

