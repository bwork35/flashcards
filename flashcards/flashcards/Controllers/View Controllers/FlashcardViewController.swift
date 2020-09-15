//
//  FlashcardViewController.swift
//  flashcards
//
//  Created by Bryan Workman on 7/20/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import UIKit

class FlashcardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var flashpileSubjectTextField: UITextField!
    @IBOutlet weak var flashpileSubjectLabel: UILabel!
    @IBOutlet weak var editButtonLabel: UIButton!
    @IBOutlet weak var quizButtonOutlet: UIButton! 
    @IBOutlet weak var subjectViewView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    //MARK: - Properties
    var flashpile: Flashpile?
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredFlashcards: [Flashcard] = []
    var titleIsEditing = false
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupSearchBar()
        loadingView.isHidden = false
        fetchFlashcards()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        updateOrCreate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
        enableQuizButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        guard let flashpile = flashpile else {return}
        print(flashpile.flashcards.count)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.backgroundColor = .bgTan
        tableView.separatorColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 0.2607020548)
        tableView.layer.cornerRadius = 15.0
        tableView.clipsToBounds = true
        
        quizButtonOutlet.layer.cornerRadius = 20.0
        quizButtonOutlet.clipsToBounds = true
        quizButtonOutlet.layer.shadowColor = UIColor.gray.cgColor
        quizButtonOutlet.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        quizButtonOutlet.layer.shadowRadius = 2.0
        quizButtonOutlet.layer.shadowOpacity = 1.0
        quizButtonOutlet.layer.masksToBounds = false
        quizButtonOutlet.layer.shadowPath = UIBezierPath(roundedRect: quizButtonOutlet.bounds, cornerRadius: quizButtonOutlet.layer.cornerRadius).cgPath
        
        loadingView.layer.cornerRadius = 20.0
        loadingView.clipsToBounds = true
        
        tableView.layer.borderWidth = 2.0
        tableView.layer.cornerRadius = 15.0
        //guard let canvaBlue = UIColor.canvaBlue else {return}
        tableView.layer.borderColor = UIColor.canvaBlue.cgColor
        
        let containerView:UIView = UIView(frame: self.tableView.frame)
        self.view.addSubview(containerView)
        self.view.addSubview(subjectViewView)
        self.view.addSubview(tableView)
        self.view.addSubview(quizButtonOutlet)
        self.view.addSubview(loadingView)
    }
    
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let flashpile = flashpile else {return}
        if !FlashpileController.shared.fauxFlashpileIDs.contains(flashpile.recordID) {
            if flashpile.flashcards.count == 0 && (flashpile.subject == "" || flashpile.subject == "Subject") {
                FlashpileController.shared.deleteFlashpile(flashpile: flashpile) { (result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            self.navigationController?.popViewController(animated: true)
                        case .failure(let error):
                            print("There was an error deleting flashpile -- \(error) -- \(error.localizedDescription)")
                        }
                    }
                }
            } else {
                FlashpileController.shared.updateFlashpile(flashpile: flashpile) { (result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            self.navigationController?.popViewController(animated: true)
                        case .failure(let error):
                            print("There was an error creating a new flashpile -- \(error) -- \(error.localizedDescription)")
                        }
                    }
                }
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        guard let flashpile = flashpile else {return}
        titleIsEditing = !titleIsEditing
        
        if titleIsEditing {
            editButtonLabel.setTitle("Done", for: .normal)
            flashpileSubjectTextField.isHidden = false
            if flashpile.subject == "Subject" {
                flashpileSubjectTextField.text = ""
            } else {
                flashpileSubjectTextField.text = flashpile.subject
            }
            flashpileSubjectLabel.isHidden = true
        } else {
            guard let text = flashpileSubjectTextField.text else {return}
            editButtonLabel.setTitle("Edit", for: .normal)
            flashpileSubjectTextField.isHidden = true
            if text == "" {
                flashpile.subject = "Subject"
            } else {
                flashpile.subject = text
                flashpileSubjectLabel.text = flashpile.subject
            }
            flashpileSubjectLabel.isHidden = false
        }
    }
    
    @IBAction func quizButtonTapped(_ sender: Any) {
        guard let flashpile = flashpile else {return}
        guard flashpile.flashcards.count > 0 else {return}
        
        if !FlashpileController.shared.fauxFlashpileIDs.contains(flashpile.recordID) {
            FlashpileController.shared.updateFlashpile(flashpile: flashpile) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        FlashcardController.shared.totalFlashcards = flashpile.flashcards
                    case .failure(_):
                        print("Error updating flashpile")
                    }
                }
            }
        } else {
            FlashcardController.shared.totalFlashcards = flashpile.flashcards
        }
    }
    
    //MARK: - Helper Methods
    func updateOrCreate() {
        if let flashpile = flashpile {
            updateViews(flashpile: flashpile)
        } else {
            FlashpileController.shared.createFlashpile(subject: "") { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let flashpile):
                        self.loadingView.isHidden = true
                        self.flashpile = flashpile
                        self.enableQuizButton()
                    case .failure(let error):
                        print("There was an error creating a new flashpile -- \(error) -- \(error.localizedDescription)")
                    }
                }
            }
            flashpileSubjectTextField.isHidden = true
            flashpileSubjectLabel.text = "Subject"
        }
    }
    
    func enableQuizButton() {
        guard let flashpile = flashpile else {return}
        if flashpile.flashcards.count == 0 {
            quizButtonOutlet.isEnabled = false
        } else {
            quizButtonOutlet.isEnabled = true
        }
    }
    
    func fetchFlashcards() {
        guard let flashpile = flashpile else {return}
        if !FlashpileController.shared.fauxFlashpileIDs.contains(flashpile.recordID) {
            FlashcardController.shared.fetchFlashcards(for: flashpile) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self.loadingView.isHidden = true
                        self.tableView.reloadData()
                        FlashcardController.shared.totalFlashcards = flashpile.flashcards
                        self.enableQuizButton()
                    case .failure(let error):
                        print("There was an error fetching flashcards for this flashpile -- \(error) -- \(error.localizedDescription)")
                    }
                }
            }
        } else {
            self.loadingView.isHidden = true
            self.addButton.isEnabled = false
            self.editButtonLabel.isEnabled = false
            self.tableView.allowsSelection = false
            FlashcardController.shared.totalFlashcards = flashpile.flashcards
        }
    }
    
    func updateViews(flashpile: Flashpile) {
        if flashpile.subject == "" {
            flashpileSubjectLabel.text = "Subject"
        } else {
            flashpileSubjectLabel.text = flashpile.subject
        }
        flashpileSubjectTextField.isHidden = true
        tableView.reloadData()
    }
    
    //search functions
    func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search flashcards"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
    }
    
    func filterContentForSearchText(_ searchText: String) {
        guard let flashpile = flashpile else {return}
        filteredFlashcards = flashpile.flashcards.filter { (flashcard: Flashcard) -> Bool in
            
            var frontString: String = ""
            var backString: String = ""
            
            if let front = flashcard.frontString {
                frontString = front
            }
            if let back = flashcard.backString {
                backString = back
            }
            return frontString.lowercased().contains(searchText.lowercased()) || backString.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    //MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredFlashcards.count
        }
        guard let flashpile = flashpile else {return 0}
        return flashpile.flashcards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "flashCell", for: indexPath) as? FlashcardTableViewCell else {return UITableViewCell()}
        guard let flashpile = flashpile else {return UITableViewCell()}
        let flashcard: Flashcard
        if isFiltering {
            flashcard = filteredFlashcards[indexPath.row]
        } else {
            flashcard = flashpile.flashcards[indexPath.row]
        }
        
        cell.flashcard = flashcard
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let flashpile = flashpile else {return}
            let flashcardToDelete = flashpile.flashcards[indexPath.row]
            guard let index = flashpile.flashcards.firstIndex(of: flashcardToDelete) else {return}
            
            FlashcardController.shared.deleteFlashcard(flashcard: flashcardToDelete) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        flashpile.flashcards.remove(at: index)
                        self.enableQuizButton()
                        FlashcardController.shared.totalFlashcards = flashpile.flashcards
                        self.tableView.reloadData()
                    case .failure(let error):
                        print("There was an error deleting this flashcard -- \(error) -- \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            guard let destinationVC = segue.destination as? FlashcardDetailViewController else {return}
            guard let flashpile = flashpile else {return}
            
            let flashcard: Flashcard
            if isFiltering {
                flashcard = filteredFlashcards[indexPath.row]
            } else {
                flashcard = flashpile.flashcards[indexPath.row]
            }
            destinationVC.flashcard = flashcard
            destinationVC.flashpile = flashpile
        } else if segue.identifier == "toAddFC" {
            guard let destinationVC = segue.destination as? FlashcardDetailViewController else {return}
            guard let flashpile = flashpile else {return}
            destinationVC.flashpile = flashpile
        }
    }
} //End of Class

extension FlashcardViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let text = searchBar.text else {return}
        filterContentForSearchText(text)
    }
} //End of extension
