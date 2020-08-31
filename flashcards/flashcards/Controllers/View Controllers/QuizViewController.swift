//
//  QuizViewController.swift
//  flashcards
//
//  Created by Bryan Workman on 7/21/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var quizFrontLabel: UILabel!
    @IBOutlet weak var quizFrontImageView: UIImageView!
    @IBOutlet weak var quizBackLabel: UILabel!
    @IBOutlet weak var quizBackImageView: UIImageView!
    @IBOutlet weak var answerButtonLabel: UIButton!
    @IBOutlet weak var skipButtonLabel: UIButton!
    @IBOutlet weak var quizProgressBar: UIProgressView!
    @IBOutlet weak var yellowProgressNums: UILabel!
    @IBOutlet weak var redProgressBar: UIProgressView!
    @IBOutlet weak var redProgressNums: UILabel!
    @IBOutlet weak var finishViewView: UIView!
    @IBOutlet weak var frontViewView: UIView!
    @IBOutlet weak var backViewView: UIView!
    @IBOutlet weak var finishedLabelView: UIView!
    @IBOutlet weak var restartButton: FlashButton!
    @IBOutlet weak var homeButton: FlashButton!
    
    //MARK: - Properties
    var quizCards = FlashcardController.shared.totalFlashcards.shuffled()
    var finalCards = FlashcardController.shared.totalFlashcards
    var quizCount = 0
    var cardCount = 0
    var correctCount = 0
    var totalCount = FlashcardController.shared.totalFlashcards.count
    var finalCount = FlashcardController.shared.totalFlashcards.count
    var skippedCards: [Flashcard] = []
    var incorrectCards: [Flashcard] = []
    var round = 1
    var redProgressBarIsOn = false
    var redCount = 0
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .bgTan
        updateViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        finishedLabelView.layer.cornerRadius = 20.0
        finishedLabelView.clipsToBounds = true
        finishedLabelView.layer.shadowColor = UIColor.gray.cgColor
        finishedLabelView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        finishedLabelView.layer.shadowRadius = 2.0
        finishedLabelView.layer.shadowOpacity = 1.0
        finishedLabelView.layer.masksToBounds = false
        finishedLabelView.layer.shadowPath = UIBezierPath(roundedRect: finishedLabelView.bounds, cornerRadius: finishedLabelView.layer.cornerRadius).cgPath
        
        frontViewView.layer.cornerRadius = 15.0
        frontViewView.clipsToBounds = true
        frontViewView.layer.shadowColor = UIColor.gray.cgColor
        frontViewView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        frontViewView.layer.shadowRadius = 2.0
        frontViewView.layer.shadowOpacity = 1.0
        frontViewView.layer.masksToBounds = false
        frontViewView.layer.shadowPath = UIBezierPath(roundedRect: frontViewView.bounds, cornerRadius: frontViewView.layer.cornerRadius).cgPath
        
        backViewView.layer.cornerRadius = 15.0
        backViewView.layer.masksToBounds = true
        backViewView.layer.shadowColor = UIColor.gray.cgColor
        backViewView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        backViewView.layer.shadowRadius = 2.0
        backViewView.layer.shadowOpacity = 1.0
        backViewView.layer.masksToBounds = false
        backViewView.layer.shadowPath = UIBezierPath(roundedRect: backViewView.bounds, cornerRadius: backViewView.layer.cornerRadius).cgPath
        
        restartButton.layer.shadowColor = UIColor.gray.cgColor
        restartButton.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        restartButton.layer.shadowRadius = 2.0
        restartButton.layer.shadowOpacity = 1.0
        restartButton.layer.masksToBounds = false
        restartButton.layer.shadowPath = UIBezierPath(roundedRect: restartButton.bounds, cornerRadius: restartButton.layer.cornerRadius).cgPath
        
        homeButton.layer.shadowColor = UIColor.gray.cgColor
        homeButton.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        homeButton.layer.shadowRadius = 2.0
        homeButton.layer.shadowOpacity = 1.0
        homeButton.layer.masksToBounds = false
        homeButton.layer.shadowPath = UIBezierPath(roundedRect: homeButton.bounds, cornerRadius: homeButton.layer.cornerRadius).cgPath
        
        yellowProgressNums.layer.shadowColor = UIColor.gray.cgColor
        yellowProgressNums.layer.shadowRadius = 0.10
        yellowProgressNums.layer.shadowOpacity = 1.0
        yellowProgressNums.layer.shadowOffset = CGSize(width: 0, height: 0.2)
        yellowProgressNums.layer.masksToBounds = false
        
        redProgressNums.layer.shadowColor = UIColor.gray.cgColor
        redProgressNums.layer.shadowRadius = 0.10
        redProgressNums.layer.shadowOpacity = 1.0
        redProgressNums.layer.shadowOffset = CGSize(width: 0, height: 0.2)
        redProgressNums.layer.masksToBounds = false
        
        frontViewView.layer.borderWidth = 2.0
        frontViewView.layer.cornerRadius = 15.0
        guard let canvaBlue = UIColor.canvaBlue else {return}
        frontViewView.layer.borderColor = canvaBlue.cgColor
        
        backViewView.layer.borderWidth = 2.0
        backViewView.layer.cornerRadius = 15.0
        backViewView.layer.borderColor = canvaBlue.cgColor
        
        finishedLabelView.layer.borderWidth = 2.0
        finishedLabelView.layer.cornerRadius = 15.0
        finishedLabelView.layer.borderColor = canvaBlue.cgColor
    }
    
    //MARK: - Actions
    @IBAction func answerButtonTapped(_ sender: Any) {
        if quizCards[quizCount].backString != nil {
            quizBackLabel.isHidden = false
            quizBackImageView.isHidden = true
        } else if quizCards[quizCount].backPhoto != nil {
            quizBackLabel.isHidden = true
            quizBackImageView.isHidden = false
        }
        answerButtonLabel.isEnabled = false
        skipButtonLabel.isEnabled = false
        backViewView.isHidden = false
    }
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        skippedCards.append(quizCards[quizCount])
        nextCard()
    }
    
    @IBAction func incorrectButtonTapped(_ sender: Any) {
        incorrectCards.append(quizCards[quizCount])
        if redProgressBarIsOn == false {
            cardCount += 1
        }
        nextCard()
    }
    
    @IBAction func correctButtonTapped(_ sender: Any) {
        if redProgressBarIsOn {
            redCount -= 1
        }
        cardCount += 1
        nextCard()
    }
    
    @IBAction func restartButtonTapped(_ sender: Any) {
        quizCards = finalCards.shuffled()
        quizCount = 0
        cardCount = 0
        correctCount = 0
        totalCount = finalCards.count
        skippedCards = []
        incorrectCards = []
        round = 1
        redProgressBarIsOn = false
        answerButtonLabel.isHidden = false
        skipButtonLabel.isHidden = false
        frontViewView.isHidden = false
        backViewView.isHidden = false
        finishViewView.isHidden = true
        quizProgressBar.progress = 0.0
        redProgressBar.progress = 0.0
        updateViews()
    }
    
    //MARK: Helper Methods
    func updateViews() {
        if quizCards[quizCount].frontString != nil {
            quizFrontLabel.isHidden = false
            quizFrontImageView.isHidden = true
            guard let frontText = quizCards[quizCount].frontString else {return}
            quizFrontLabel.text = frontText
        } else if quizCards[quizCount].frontPhoto != nil {
            quizFrontLabel.isHidden = true
            quizFrontImageView.isHidden = false
            guard let frontImage = quizCards[quizCount].frontPhoto else {return}
            quizFrontImageView.image = frontImage
        } else {
            quizFrontLabel.isHidden = true
            quizFrontImageView.isHidden = true
        }
        
        if quizCards[quizCount].backString != nil {
            guard let backText = quizCards[quizCount].backString else {return}
            quizBackLabel.text = backText
        } else if quizCards[quizCount].backPhoto != nil {
            guard let backImage = quizCards[quizCount].backPhoto else {return}
            quizBackImageView.image = backImage
        } else {
            quizBackLabel.isHidden = true
            quizBackImageView.isHidden = true
        }
    
        updateProgressBar()
        
        answerButtonLabel.isEnabled = true
        skipButtonLabel.isEnabled = true
        quizBackLabel.isHidden = true
        quizBackImageView.isHidden = true
        backViewView.isHidden = true
        finishViewView.isHidden = true
    }
    
    func nextCard() {
        quizCount += 1
        if quizCount < quizCards.count && quizCards.count > 0 {
            round = 1
        } else if quizCount == quizCards.count && skippedCards.count > 0 {
            round = 2
        } else if quizCount == quizCards.count && incorrectCards.count > 0 && redProgressBarIsOn == false {
            round = 3
        } else if quizCount == quizCards.count && incorrectCards.count > 0 && redProgressBarIsOn == true {
            round = 4
        } else {
            round = 5
        }
        
        switch round {
        case 1:
            updateViews()
        case 2:
            correctCount += (quizCount - skippedCards.count)
            quizCards = skippedCards
            skippedCards = []
            quizCount = 0
            round = 1
            updateViews()
        case 3:
            quizCards = incorrectCards.shuffled()
            redCount = incorrectCards.count
            incorrectCards = []
            quizCount = 0
            round = 1
            redProgressBarIsOn = true
            quizProgressBar.progress = 1.0
            cardCount = 0
            totalCount = quizCards.count
            updateViews()
        case 4:
            quizCards = incorrectCards.shuffled()
            incorrectCards = []
            quizCount = 0
            round = 1
            updateViews()
        default:
            redProgressBar.progress = 1.0
            finishQuiz()
        }
    }
    
    func finishQuiz() {
        if redProgressBarIsOn == false {
            yellowProgressNums.text = "\(finalCount) / \(finalCount)"
            quizProgressBar.progress = 1.0
            redProgressBar.progress = 0.0
        }
        redProgressNums.text = "0"
        quizFrontImageView.isHidden = true
        quizBackImageView.isHidden = true
        quizFrontLabel.isHidden = true
        quizBackLabel.isHidden = true
        answerButtonLabel.isHidden = true
        skipButtonLabel.isHidden = true
        finishViewView.isHidden = false
        frontViewView.isHidden = true
        backViewView.isHidden = true
    }
    
    func updateProgressBar() {
        if redProgressBarIsOn == false {
            if round == 1 {
                yellowProgressNums.text = "\(correctCount + quizCount - skippedCards.count) / \(finalCount)"
                quizProgressBar.progress = (Float(cardCount))/(Float(totalCount))
            }
            redProgressNums.text = "\(incorrectCards.count)"
            redProgressBar.progress = 0.0
        } else {
            yellowProgressNums.text = "\(finalCount) / \(finalCount)"
            redProgressNums.text = "\(redCount)"
            redProgressBar.progress = (Float(cardCount))/(Float(totalCount))
        }
    }
} //End of class
