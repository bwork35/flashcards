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
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = .bgTan
        navigationItem.leftBarButtonItem = editButtonItem
        setupSearchBar()
//        fetchFlashpiles()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchFlashpiles()
        collectionView.reloadData()
        FlashcardController.shared.totalFlashcards = []
    }
    
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
    
    func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Seach Flashpiles"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        //navigationItem.hidesSearchBarWhenScrolling = false
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
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

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
            
            for flashcard in flashpileToDelete.flashcards {
                FlashcardController.shared.deleteFlashcard(flashcard: flashcard) { (result) in
                    switch result {
                    case .success(_):
                        print("deleted flashcard")
                    case .failure(let error):
                        print("There was an error deleting a flashcard from this flashpile -- \(error) -- \(error.localizedDescription)")
                    }
                }
            }
            
            FlashpileController.shared.deleteFlashpile(flashpile: flashpileToDelete) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        //self.collectionView?.deleteItems(at: [indexPath])
                        
                        self.fetchFlashpiles()
                    case .failure(let error):
                        print("There was an error deleting the flashpile -- \(error) -- \(error.localizedDescription)")
                    }
                }
            }
        }
    }
} //End of Extension
