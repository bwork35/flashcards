//
//  FlashButton.swift
//  flashcards
//
//  Created by Bryan Workman on 7/24/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import UIKit

class FlashSelectTypeButton: UIButton {
    
    override func awakeFromNib() {
        setupView()
    }
    
    func setupView() {
        self.tintColor = .systemBlue
        self.setPreferredSymbolConfiguration(.init(pointSize: 22.0, weight: .unspecified), forImageIn: .normal)
    }
} //End of class

class FlashSelectTypeButtonBold: FlashSelectTypeButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
        self.setPreferredSymbolConfiguration(.init(pointSize: 25.0, weight: .bold), forImageIn: .normal)
    }
    
} //End of class
