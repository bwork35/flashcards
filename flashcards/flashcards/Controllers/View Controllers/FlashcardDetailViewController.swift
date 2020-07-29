//
//  FlashcardDetailViewController.swift
//  flashcards
//
//  Created by Bryan Workman on 7/18/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import UIKit

//enum selectedFlashButtonType {
//    case text
//    case picture
//    case pencil
//}

class FlashcardDetailViewController: UIViewController, UINavigationControllerDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var frontTextField: UITextField!
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var frontSelectImageLabel: UIButton!
    @IBOutlet weak var frontTextButtonOutlet: UIButton!
    @IBOutlet weak var frontPictureButtonOutlet: UIButton!
    @IBOutlet weak var frontPencilButtonOutlet: UIButton!
    @IBOutlet weak var backTextField: UITextField!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var backSelectImageLabel: UIButton!
    @IBOutlet weak var backTextButtonOutlet: UIButton!
    @IBOutlet weak var backPictureButtonOutlet: UIButton!
    @IBOutlet weak var backPencilButtonOutlet: UIButton!
    
    //MARK: - Properties
    var flashcard: Flashcard?
    var flashpile: Flashpile?
    
    var frontTextIsSelected = false
    var frontPictureIsSelected = false
    var frontPencilIsSelected = false
    var backTextIsSelected = false
    var backPictureIsSelected = false
    var backPencilIsSelected = false
    var frontImagePickerSelected = true
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        if let flashcard = flashcard {
            print("yes")
        } else {
            print("no")
        }
        if let flashcard = flashcard {
            updateViews(flashcard: flashcard)
        } else {
            frontTextSelected()
            backTextSelected()
        }
//        if let flashpile = flashpile {
//            print("flashpile exists")
//        } else {
//            FlashpileController.shared.createFlashpile(subject: "") { (result) in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(_):
//                        self.flashpile = FlashpileController.shared.totalFlashpiles.last
//                        print("We fuckin did it!")
//                        print(self.flashpile?.subject)
//                    case .failure(let error):
//                        print("There was an error creating a new flashpile -- \(error) -- \(error.localizedDescription)")
//                    }
//                }
//            }
//        }
    }
    
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let flashpile = flashpile else {return}
            var front: Any
            var back: Any
        
            if frontTextIsSelected {
                guard let frontText = frontTextField.text, !frontText.isEmpty else {return}
                front = frontText
            } else if frontPictureIsSelected {
                guard let frontImage = frontImageView.image else {return}
                front = frontImage
            } else {
                front = ""
            }
            
            if backTextIsSelected {
                guard let backText = backTextField.text, !backText.isEmpty else {return}
                back = backText
            } else if backPictureIsSelected {
                guard let backImage = backImageView.image else {return}
                back = backImage
            } else {
                back = ""
            }
            
            if let flashcard = flashcard {
                print("it was a fc")
                flashcard.front = front
                flashcard.back = back
                FlashcardController.shared.updateFlashcard(flashcard: flashcard) { (result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            print("updated :)")
                        case .failure(let error):
                            print("There was an error updating the flashcard -- \(error) -- \(error.localizedDescription)")
                        }
                    }
                }
            } else {
                FlashcardController.shared.createFlashcard(front: front, back: back, flashpile: flashpile) { (result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            //self.navigationController?.popViewController(animated: true)
                            print("saved flashcard")
                             
                        case .failure(let error):
                            print("There was an error creating flashcard -- \(error) -- \(error.localizedDescription)")
                        }
                    }
                }
            }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func saveButtonActions() {
        
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func frontTextButtonTapped(_ sender: Any) {
        frontTextSelected()
    }
    @IBAction func frontPictureButtonTapped(_ sender: Any) {
        frontPictureSelected()
    }
    @IBAction func frontPencilButtonTapped(_ sender: Any) {
        frontPencilSelected()
    }
    @IBAction func backTextButtonTapped(_ sender: Any) {
        backTextSelected()
    }
    @IBAction func backPictureButtonTapped(_ sender: Any) {
        backPictureSelected()
    }
    @IBAction func backPencilButtonTapped(_ sender: Any) {
        backPencilSelected()
    }
    @IBAction func frontSelectImageTapped(_ sender: Any) {
        frontImagePickerSelected = true
        
        let alertController = UIAlertController(title: "Select an image", message: "From where would you like to select an image?", preferredStyle: .alert)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    @IBAction func backSelectImageTapped(_ sender: Any) {
        frontImagePickerSelected = false
        
        let alertController = UIAlertController(title: "Select an image", message: "From where would you like to select an image?", preferredStyle: .alert)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    //MARK: - Helper Methods
    func updateViews(flashcard: Flashcard) {
        if flashcard.front is String {
            frontTextSelected()
            frontTextField.text = flashcard.front as? String
        } else if flashcard.front is UIImage {
            frontPictureSelected()
            frontSelectImageLabel.setTitle("", for: .normal)
            frontImageView.image = flashcard.front as? UIImage
        } else {
            frontPencilSelected()
        }
        
        if flashcard.back is String {
            backTextSelected()
            backTextField.text = flashcard.back as? String
        } else if flashcard.back is UIImage {
            backPictureSelected()
            backSelectImageLabel.setTitle("", for: .normal)
            backImageView.image = flashcard.back as? UIImage
        } else {
            backPencilSelected()
        }
        
    }
    
    func frontTextSelected() {
        frontTextIsSelected = true
        frontPictureIsSelected = false
        frontPencilIsSelected = false
        
        frontTextField.isHidden = false
        frontImageView.isHidden = true
        frontSelectImageLabel.isHidden = true
        
//        frontTextButtonOutlet = FlashSelectTypeButtonBold()
        frontTextButtonOutlet.tintColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
        frontTextButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 25.0, weight: .bold), forImageIn: .normal)
        frontPictureButtonOutlet.tintColor = .systemBlue
        frontPictureButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 21.0, weight: .unspecified), forImageIn: .normal
        )
        frontPencilButtonOutlet.tintColor = .systemBlue
        frontPencilButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 22.0, weight: .unspecified), forImageIn: .normal)
    }
    func frontPictureSelected() {
        frontTextIsSelected = false
        frontPictureIsSelected = true
        frontPencilIsSelected = false
        
        frontTextField.isHidden = true
        frontImageView.isHidden = false
        frontSelectImageLabel.isHidden = false
        
        frontTextButtonOutlet.tintColor = .systemBlue
        frontTextButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 22.0, weight: .unspecified), forImageIn: .normal)
        frontPictureButtonOutlet.tintColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        frontPictureButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 25.0, weight: .bold), forImageIn: .normal
        )
        frontPencilButtonOutlet.tintColor = .systemBlue
        frontPencilButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 22.0, weight: .unspecified), forImageIn: .normal)
    }
    func frontPencilSelected() {
        frontTextIsSelected = false
        frontPictureIsSelected = false
        frontPencilIsSelected = true
        
        frontTextField.isHidden = true
        frontImageView.isHidden = true
        frontSelectImageLabel.isHidden = true
        
        frontTextButtonOutlet.tintColor = .systemBlue
        frontTextButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 22.0, weight: .unspecified), forImageIn: .normal)
        frontPictureButtonOutlet.tintColor = .systemBlue
        frontPictureButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 21.0, weight: .unspecified), forImageIn: .normal
        )
        frontPencilButtonOutlet.tintColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        frontPencilButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 25.0, weight: .bold), forImageIn: .normal)
    }
    func backTextSelected() {
        backTextIsSelected = true
        backPictureIsSelected = false
        backPencilIsSelected = false
        
        backTextField.isHidden = false
        backImageView.isHidden = true
        backSelectImageLabel.isHidden = true
        
            backTextButtonOutlet.tintColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
            backTextButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 25.0, weight: .bold), forImageIn: .normal)
            backPictureButtonOutlet.tintColor = .systemBlue
            backPictureButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 21.0, weight: .unspecified), forImageIn: .normal
            )
            backPencilButtonOutlet.tintColor = .systemBlue
            backPencilButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 22.0, weight: .unspecified), forImageIn: .normal)
        }
        func backPictureSelected() {
            backTextIsSelected = false
            backPictureIsSelected = true
            backPencilIsSelected = false
            
            backTextField.isHidden = true
            backImageView.isHidden = false
            backSelectImageLabel.isHidden = false
            
            backTextButtonOutlet.tintColor = .systemBlue
            backTextButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 22.0, weight: .unspecified), forImageIn: .normal)
            backPictureButtonOutlet.tintColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
            backPictureButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 25.0, weight: .bold), forImageIn: .normal
            )
            backPencilButtonOutlet.tintColor = .systemBlue
            backPencilButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 22.0, weight: .unspecified), forImageIn: .normal)
        }
        func backPencilSelected() {
            backTextIsSelected = false
            backPictureIsSelected = false
            backPencilIsSelected = true
            
            backTextField.isHidden = true
            backImageView.isHidden = true
            backSelectImageLabel.isHidden = true
            
            backTextButtonOutlet.tintColor = .systemBlue
            backTextButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 22.0, weight: .unspecified), forImageIn: .normal)
            backPictureButtonOutlet.tintColor = .systemBlue
            backPictureButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 21.0, weight: .unspecified), forImageIn: .normal
            )
            backPencilButtonOutlet.tintColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
            backPencilButtonOutlet.setPreferredSymbolConfiguration(.init(pointSize: 25.0, weight: .bold), forImageIn: .normal)
        }
    
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //saveButtonActions()
        
        
        print("segue")
    
        //guard let flashpile = flashpile else {return}
        //print(flashpile.flashcards.count)
        //guard let destinationVC = segue.destination as? FlashcardViewController else {return}
        //destinationVC.flashpile = flashpile
    }
    
    
} //End of class

extension FlashcardDetailViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as? UIImage else {return}
        
        if frontImagePickerSelected {
            frontSelectImageLabel.setTitle("", for: .normal)
            frontImageView.image = selectedImage
        } else {
            backSelectImageLabel.setTitle("", for: .normal)
            backImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
}
