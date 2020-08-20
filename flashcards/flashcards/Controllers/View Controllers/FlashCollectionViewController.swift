//
//  FlashCollectionViewController.swift
//  flashcards
//
//  Created by Bryan Workman on 7/16/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import UIKit

private let reuseIdentifier = "flashpileCell"

class FlashCollectionViewController: UICollectionViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var addButtonOutlet: UIBarButtonItem!
    
    //MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    var filteredFlashpiles: [Flashpile] = []
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    let defaults = UserDefaults.standard
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = .bgTan
        navigationItem.leftBarButtonItem = editButtonItem
        setupSearchBar()
        
       // FlashpileController.shared.createMultiplication(completion: collectionView.reloadData)
       //FlashpileController.shared.createPeriodicTable(completion: collectionView.reloadData)
        //FlashpileController.shared.createStatesAndCapitals(completion: collectionView.reloadData)
        
//        if defaults.bool(forKey: "First Launch") == false {
//            //FlashpileController.shared.createMultiplication()
//            //FlashpileController.shared.createPeriodicTable()
//            //FlashpileController.shared.createStatesAndCapitals()
//            defaults.set(false, forKey: "First Launch")
//        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchFlashpiles()
        FlashcardController.shared.totalFlashcards = []
    }
    
    //MARK: - Actions
     @IBAction func unwindToHome(_ sender: UIStoryboardSegue) {}
    
    //MARK: - Helper Methods
    func fetchFlashpiles() {
        FlashpileController.shared.fetchAllFlashpiles { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.collectionView.reloadData()
                case .failure(let error):
                    print("There was an error fetching flashpiles -- \(error) -- \(error.localizedDescription)")
                }
            }
        }
    }
    
    //Search functions
    func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Flashpiles"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
    }
    func filterContentForSearchText(_ searchText: String) {
        filteredFlashpiles = FlashpileController.shared.totalFlashpiles.filter { (flashpile: Flashpile) -> Bool in
            return flashpile.subject.lowercased().contains(searchText.lowercased())
        }
        collectionView.reloadData()
    }
    
    //MARK: - Delete Items
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        addButtonOutlet.isEnabled = !editing
        if let indexPaths = collectionView?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                if let cell = collectionView?.cellForItem(at: indexPath) as? FlashpileCollectionViewCell {
                    cell.isEditing = editing 
                }
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering {
            return filteredFlashpiles.count
        }
        return FlashpileController.shared.totalFlashpiles.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? FlashpileCollectionViewCell else {return UICollectionViewCell()}
    
        let flashpile: Flashpile
        if isFiltering {
            flashpile = filteredFlashpiles[indexPath.row]
        } else {
            flashpile = FlashpileController.shared.totalFlashpiles[indexPath.row]
        }
        
        if editButtonItem.title == "Edit" {
            cell.isEditing = false
        }
        
        cell.flashpile = flashpile
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFlashList" {
            guard let cell = sender as? UICollectionViewCell else {return}
            guard let indexPath = collectionView.indexPath(for: cell) else {return}
            guard let destinationVC = segue.destination as? FlashcardViewController else {return}
            
            let flashpile: Flashpile
            if isFiltering {
                flashpile = filteredFlashpiles[indexPath.row]
            } else {
                flashpile = FlashpileController.shared.totalFlashpiles[indexPath.row]
            }
            destinationVC.flashpile = flashpile
        }
    }
} //End of Class

extension FlashCollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let text = searchBar.text else {return}
        filterContentForSearchText(text)
    }
} //End of Extension

extension FlashCollectionViewController: FlashpileCellDelegate {
    func delete(cell: FlashpileCollectionViewCell) {
        if let indexPath = collectionView?.indexPath(for: cell) {
            let flashpileToDelete = FlashpileController.shared.totalFlashpiles[indexPath.row]
            
            let alertController = UIAlertController(title: "Delete", message: "Are you sure you want to delete the flashpile \"\(flashpileToDelete.subject)\" ?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                FlashpileController.shared.deleteFlashpile(flashpile: flashpileToDelete) { (result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            self.fetchFlashpiles()
                        case .failure(let error):
                            print("There was an error deleting the flashpile -- \(error) -- \(error.localizedDescription)")
                        }
                    }
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            self.present(alertController, animated: true)
        }
    }
} //End of Extension
