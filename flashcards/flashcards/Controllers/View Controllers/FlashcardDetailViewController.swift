//
//  FlashcardDetailViewController.swift
//  flashcards
//
//  Created by Bryan Workman on 7/18/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import UIKit

class FlashcardDetailViewController: UIViewController, UINavigationControllerDelegate, UITextViewDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var frontTextView: UITextView!
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var frontSelectImageLabel: UIButton!
    @IBOutlet weak var frontTextButtonOutlet: UIButton!
    @IBOutlet weak var frontPictureButtonOutlet: UIButton!
    @IBOutlet weak var frontPencilButtonOutlet: UIButton!
    @IBOutlet weak var backTextView: UITextView!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var backSelectImageLabel: UIButton!
    @IBOutlet weak var backTextButtonOutlet: UIButton!
    @IBOutlet weak var backPictureButtonOutlet: UIButton!
    @IBOutlet weak var backPencilButtonOutlet: UIButton!
    @IBOutlet weak var frontPencilKitImageView: UIImageView!
    @IBOutlet weak var backPencilKitImageView: UIImageView!
    @IBOutlet weak var frontViewView: UIView!
    @IBOutlet weak var backViewView: UIView!
    
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
        self.view.backgroundColor = .bgTan
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
         view.addGestureRecognizer(tap)
        
//         NotificationCenter.default.addObserver(self, selector: #selector(FlashcardDetailViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//
//         NotificationCenter.default.addObserver(self, selector: #selector(FlashcardDetailViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let flashcard = flashcard {
            updateViews(flashcard: flashcard)
        } else {
            frontTextSelected()
            backTextSelected()
        }
        setupTextViews()
    }
    
    override func viewDidLayoutSubviews() {
        frontViewView.layer.cornerRadius = 15.0
        frontViewView.clipsToBounds = true
        backViewView.layer.cornerRadius = 15.0
        backViewView.clipsToBounds = true
        
        frontViewView.layer.shadowColor = UIColor.gray.cgColor
        frontViewView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        frontViewView.layer.shadowRadius = 2.0
        frontViewView.layer.shadowOpacity = 1.0
        frontViewView.layer.masksToBounds = false
        frontViewView.layer.shadowPath = UIBezierPath(roundedRect: frontViewView.bounds, cornerRadius: frontViewView.layer.cornerRadius).cgPath
        
        backViewView.layer.shadowColor = UIColor.gray.cgColor
        backViewView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        backViewView.layer.shadowRadius = 2.0
        backViewView.layer.shadowOpacity = 1.0
        backViewView.layer.masksToBounds = false
        backViewView.layer.shadowPath = UIBezierPath(roundedRect: backViewView.bounds, cornerRadius: backViewView.layer.cornerRadius).cgPath
        
//        frontTextView.layer.cornerRadius = 40.0
//        frontTextView.clipsToBounds = true
//        backTextView.layer.cornerRadius = 40.0
//        backTextView.clipsToBounds = true
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
            guard let frontText = frontTextView.text, !frontText.isEmpty else {return}
            frontString = frontText
        } else if frontPictureIsSelected {
            guard let frontImage = frontImageView.image else {return}
            frontPhoto = frontImage
        } else {
            guard let frontImage = frontPencilKitImageView.image else {return}
            frontPhoto = frontImage
        }
        
        if backTextIsSelected {
            guard let backText = backTextView.text, !backText.isEmpty else {return}
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
                        self.navigationController?.popViewController(animated: true)
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
                        guard let flashcard = flashpile.flashcards.last else {return}
                        FlashcardController.shared.totalFlashcards.append(flashcard)
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        print("There was an error creating flashcard -- \(error) -- \(error.localizedDescription)")
                    }
                }
            }
        }
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
    
    func setupTextViews() {
        frontTextView.delegate = self
        backTextView.delegate = self
        
        if frontTextView.text.isEmpty {
            frontTextView.text = "front text..."
            frontTextView.textColor = UIColor.lightGray
        }
        if backTextView.text.isEmpty {
            backTextView.text = "back text..."
            backTextView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            if textView == frontTextView {
                textView.text = "front text..."
            } else if textView == backTextView {
                textView.text = "back text..."
            }
            textView.textColor = UIColor.lightGray
        }
    }
    
//    @objc func keyboardWillShow(notification: NSNotification) {
//        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
//
//        self.view.frame.origin.y = 0 - keyboardSize.height
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//      self.view.frame.origin.y = 0
//    }
    
    func updateViews(flashcard: Flashcard) {
        if let frontString = flashcard.frontString {
            frontTextSelected()
            frontTextView.text = frontString
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
            backTextView.text = backString
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
        
        frontTextView.isHidden = false
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
        
        frontTextView.isHidden = true
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
        
        frontTextView.isHidden = true
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
        
        backTextView.isHidden = false
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
        
        backTextView.isHidden = true
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
        
        backTextView.isHidden = true
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
} //End of extension


