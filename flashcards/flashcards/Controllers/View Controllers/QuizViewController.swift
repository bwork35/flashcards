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
    @IBOutlet weak var incorrectButtonLabel: UIButton!
    @IBOutlet weak var correctButtonLabel: UIButton!
    @IBOutlet weak var quizProgressBar: UIProgressView!
    @IBOutlet weak var redProgressBar: UIProgressView!
    
    //MARK: - Properties
    var quizCards = FlashcardController.shared.totalFlashcards.shuffled()
    var quizCount = 0
    var cardCount = 0
    var totalCount = FlashcardController.shared.totalFlashcards.count
    var skippedCards: [Flashcard] = []
    var incorrectCards: [Flashcard] = []
    var round = 1
    var redProgressBarIsOn = false
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
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
        incorrectButtonLabel.isHidden = false
        correctButtonLabel.isHidden = false
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
        cardCount += 1
        nextCard()
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
        incorrectButtonLabel.isHidden = true
        correctButtonLabel.isHidden = true
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
            print("Round 2")
            quizCards = skippedCards
            skippedCards = []
            quizCount = 0
            round = 1
            updateViews()
        case 3:
            print("Round 3")
            quizCards = incorrectCards.shuffled()
            incorrectCards = []
            quizCount = 0
            round = 1
            redProgressBarIsOn = true
            quizProgressBar.progress = 1.0
            cardCount = 0
            totalCount = quizCards.count
            updateViews()
        case 4:
            print("Round 4")
            quizCards = incorrectCards.shuffled()
            incorrectCards = []
            quizCount = 0
            round = 1
            updateViews()
        default:
            redProgressBar.progress = 1.0
            print("Round 5")
            finishQuiz()
        }
    }
    
    func finishQuiz() {
        if redProgressBarIsOn == false {
            quizProgressBar.progress = 1.0
            redProgressBar.progress = 0.0
        }
        quizFrontImageView.isHidden = true
        quizBackImageView.isHidden = true
        quizFrontLabel.isHidden = true
        quizBackLabel.isHidden = true
        answerButtonLabel.isHidden = true
        skipButtonLabel.isHidden = true
        incorrectButtonLabel.isHidden = true
        correctButtonLabel.isHidden = true
    }
    
    func updateProgressBar() {
        if redProgressBarIsOn == false {
            redProgressBar.progress = 0.0
            quizProgressBar.progress = (Float(cardCount))/(Float(totalCount))
        } else {
            redProgressBar.progress = (Float(cardCount))/(Float(totalCount))
        }
    }
    
} //End of class
