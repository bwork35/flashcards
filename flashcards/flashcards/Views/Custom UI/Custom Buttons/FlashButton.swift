//
//  FlashButton.swift
//  flashcards
//
//  Created by Bryan Workman on 8/2/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import UIKit

class FlashButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    func setupView() {
        self.layer.cornerRadius = 20.0
        self.clipsToBounds = true
        self.backgroundColor = .buttonGray
        
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
    }
    
} //End of class
