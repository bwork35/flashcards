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
    
    //MARK: - Properties
    var flashpile: Flashpile?

    let searchController = UISearchController(searchResultsController: nil)
    var filteredFlashcards: [Flashcard] = []
    
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
       
        if let flashpile = flashpile {
            updateViews(flashpile: flashpile)
        } else {
            FlashpileController.shared.createFlashpile(subject: "") { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self.flashpile = FlashpileController.shared.totalFlashpiles.last
                    case .failure(let error):
                        print("There was an error creating a new flashpile -- \(error) -- \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchFlashcards()
    }
    
    //MARK: - Actions
    @IBAction func unwindToTableView(_ sender: UIStoryboardSegue) {
        print("unwind")
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let text = flashpileSubjectTextField.text, !text.isEmpty else {return}
        
        guard let flashpile = flashpile else {return}
        flashpile.subject = text
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
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Helper Methods
    
    func fetchFlashcards() {
        guard let flashpile = flashpile else {return}
        FlashcardController.shared.fetchFlashcards(for: flashpile) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.tableView.reloadData()
                case .failure(let error):
                    print("There was an error fetching flashcards for this flashpile -- \(error) -- \(error.localizedDescription)")
                }
            }
        }
    }
    
    func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search flashcards"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
    }
    
//    func updateFlashArray(){
//        guard let flashpile = flashpile else {return}
//        flashpile.flashcards = FlashcardController.shared.totalFlashcards
//    }
    
    func updateViews(flashpile: Flashpile) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.flashpileSubjectTextField.text = flashpile.subject
        }
        //FlashcardController.shared.totalFlashcards = flashpile.flashcards
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredFlashcards = FlashcardController.shared.totalFlashcards.filter { (flashcard: Flashcard) -> Bool in
            guard let frontString = flashcard.frontString else {return false}
            guard let backString = flashcard.backString else {return false}
            return frontString.lowercased().contains(searchText.lowercased()) || backString.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
   
    
    //MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredFlashcards.count
        }
        //return FlashcardController.shared.totalFlashcards.count
        guard let flashpile = flashpile else {return 0}
        print("rowsD: \(flashpile.flashcards.count)")
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
                       // self.fetchFlashcards()
                        self.tableView.reloadData()
                    case .failure(let error):
                        print("There was an error deleting this flashcard -- \(error) -- \(error.localizedDescription)")
                    }
                }
            }
            //tableView.reloadData()
        }
        //updateFlashArray()
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
            //guard let indexPath = tableView.indexPathForSelectedRow else {return}
            guard let destinationVC = segue.destination as? FlashcardDetailViewController else {return}
            guard let flashpile = flashpile else {return}
            
//            let flashcard: Flashcard
//            if isFiltering {
//                flashcard = filteredFlashcards[indexPath.row]
//            } else {
//                flashcard = flashpile.flashcards[indexPath.row]
//            }
//            destinationVC.flashcard = flashcard
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
}

