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
        self.font = UIFont.boldSystemFont(ofSize: 27.0)
        
        let strokeTextAttributes = [
            NSAttributedString.Key.strokeColor : UIColor.titleRed,
            //NSAttributedString.Key.foregroundColor : UIColor.yellow,
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
        self.font = UIFont.boldSystemFont(ofSize: 25.0)
    }
} //End of class

class QuizLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.font = UIFont(name: "Gill Sans", size: 22.0)
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 0.25
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.masksToBounds = false
    }
} //End of class

class CoverLabel: FlashLabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        self.font = UIFont.systemFont(ofSize: 18.0, weight: .medium)
        self.font = UIFont(name: "Avenir", size: 18.0)
//
//        self.textColor = #colorLiteral(red: 0.9658536315, green: 1, blue: 0, alpha: 1)
//        self.font = UIFont.systemFont(ofSize: 25.0, weight: .heavy)
//        let strokeTextAttributes = [
//            NSAttributedString.Key.strokeColor : UIColor.black,
//            //NSAttributedString.Key.foregroundColor : UIColor.yellow,
//            NSAttributedString.Key.strokeWidth : -2.0
//            ] as [NSAttributedString.Key : Any]
//
//        self.attributedText = NSMutableAttributedString(string: self.text!, attributes: strokeTextAttributes)
//
//        self.layer.borderColor = UIColor.black.cgColor
//        self.layer.shadowRadius = 0.25
//        self.layer.shadowOffset = CGSize(width: 0, height: 0)
//        self.font = UIFont.boldSystemFont(ofSize: 26.0)
    }
} //End of class
