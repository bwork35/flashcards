//
//  FlashcardDetailViewController.swift
//  flashcards
//
//  Created by Bryan Workman on 7/18/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var frontPencilKitImageView: UIImageView!
    @IBOutlet weak var backPencilKitImageView: UIImageView!
    
    //MARK: - Properties
    var flashcard: Flashcard?
    var flashpile: Flashpile?
    
    var frontImg = UIImage() {
        didSet {
            frontPencilIsSelected = true
        }
    }
    var backImg = UIImage() {
        didSet {
            backPencilIsSelected = true
        }
    }
    var isFrontPencil = true
    
    var frontTextIsSelected = false
    var frontPictureIsSelected = false
    var frontPencilIsSelected = false
    var backTextIsSelected = false
    var backPictureIsSelected = false
    var backPencilIsSelected = false
    var frontImagePickerSelected = true
    
    //MARK: - Lifecycles
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        frontPencilKitImageView.image = frontImg
        backPencilKitImageView.image = backImg
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let flashcard = flashcard {
            updateViews(flashcard: flashcard)
        } else {
            frontTextSelected()
            backTextSelected()
        }
    }
    
    //MARK: - Actions
    @IBAction func unwindToDetail(_ sender: UIStoryboardSegue) {}
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let flashpile = flashpile else {return}
        var frontString: String?
        var backString: String?
        var frontPhoto: UIImage?
        var backPhoto: UIImage?
        
        if frontTextIsSelected {
            guard let frontText = frontTextField.text, !frontText.isEmpty else {return}
            frontString = frontText
        } else if frontPictureIsSelected {
            guard let frontImage = frontImageView.image else {return}
            frontPhoto = frontImage
        } else {
            guard let frontImage = frontPencilKitImageView.image else {return}
            frontPhoto = frontImage
        }
        
        if backTextIsSelected {
            guard let backText = backTextField.text, !backText.isEmpty else {return}
            backString = backText
        } else if backPictureIsSelected {
            guard let backImage = backImageView.image else {return}
            backPhoto = backImage
        } else {
            guard let backImage = backPencilKitImageView.image else {return}
            backPhoto = backImage
        }
        
        if let flashcard = flashcard {
            flashcard.frontString = frontString
            flashcard.backString = backString
            flashcard.frontPhoto = frontPhoto
            flashcard.backPhoto = backPhoto
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
            FlashcardController.shared.createFlashcard(frontString: frontString, backString: backString, frontPhoto: frontPhoto, backPhoto: backPhoto, flashpile: flashpile) { (result) in
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
        isFrontPencil = true
        frontPencilSelected()
    }
    @IBAction func backTextButtonTapped(_ sender: Any) {
        backTextSelected()
    }
    @IBAction func backPictureButtonTapped(_ sender: Any) {
        backPictureSelected()
    }
    @IBAction func backPencilButtonTapped(_ sender: Any) {
        isFrontPencil = false
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
        if let frontString = flashcard.frontString {
            frontTextSelected()
            frontTextField.text = frontString
        } else if let frontPhoto = flashcard.frontPhoto {
            frontPictureSelected()
            frontSelectImageLabel.setTitle("", for: .normal)
            frontImageView.image = frontPhoto
        } else {
            frontPencilSelected()
            frontPencilKitImageView.image = flashcard.frontPhoto
        }
        
        if let backString = flashcard.backString {
            backTextSelected()
            backTextField.text = backString
        } else if let backPhoto = flashcard.backPhoto {
            backPictureSelected()
            backSelectImageLabel.setTitle("", for: .normal)
            backImageView.image = backPhoto
        } else {
            backPencilSelected()
            backPencilKitImageView.image = flashcard.backPhoto
        }
        
    }
    
    func frontTextSelected() {
        frontTextIsSelected = true
        frontPictureIsSelected = false
        frontPencilIsSelected = false
        
        frontTextField.isHidden = false
        frontImageView.isHidden = true
        frontSelectImageLabel.isHidden = true
        frontPencilKitImageView.isHidden = true
        
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
        frontPencilKitImageView.isHidden = true
        
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
        frontPencilKitImageView.isHidden = false
        
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
        backPencilKitImageView.isHidden = true
        
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
        backPencilKitImageView.isHidden = true
        
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
        backPencilKitImageView.isHidden = false
        
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
        
        if segue.identifier == "toPencilKitView" {
            guard let destinationVC = segue.destination as? PencilViewController else {return}
            destinationVC.isFrontPencil = isFrontPencil
        }
        
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
