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
        addButtonOutlet.isEnabled = true
        editButtonItem.isEnabled = true
        
        //defaults.set(false, forKey: "DidDeleteMultPile")
        //defaults.set(false, forKey: "DidDeleteElementPile")
        //defaults.set(false, forKey: "DidDeleteCapitalsPile")
        createFauxPiles()
        
        fetchAppleUser()
        NotificationCenter.default.addObserver(
            self, selector: #selector(fetchAppleUser),
            name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchFlashpiles()
        FlashcardController.shared.totalFlashcards = []
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Actions
    @IBAction func unwindToHome(_ sender: UIStoryboardSegue) {}
    
    //MARK: - Helper Methods
    @objc func fetchAppleUser() {
        AppleUserController.shared.fetchAppleUserReference { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("Apple User fetch successfully.")
                    self.addButtonOutlet.isEnabled = true
                    self.editButtonItem.isEnabled = true
                    self.fetchFlashpiles()
                case .failure(_):
                    self.addButtonOutlet.isEnabled = false
                    self.editButtonItem.isEnabled = false
                    self.removeApplePiles()
                    self.presentAppleVC()
                }
            }
        }
    }
    
    func removeApplePiles() {
        FlashpileController.shared.totalFlashpiles = FlashpileController.shared.fauxFlashpiles
        self.collectionView.reloadData()
    }
    
    func presentAppleVC() {
        let FlashVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "AppleIDVC")
        FlashVC.modalPresentationStyle = .automatic
        self.present(FlashVC, animated: true, completion: nil)
    }
    
    func presentCloudErrorVC() {
        let ErrorVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "CloudErrorVC")
        ErrorVC.modalPresentationStyle = .automatic
        self.present(ErrorVC, animated: true, completion: nil)
    }
    
    func fetchFlashpiles() {
        FlashpileController.shared.fetchAllFlashpiles { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.addButtonOutlet.isEnabled = true
                    self.editButtonItem.isEnabled = true
                    self.collectionView.reloadData()
                case .failure(let error):
                    print("There was an error fetching flashpiles -- \(error) -- \(error.localizedDescription)")
                    if error.localizedDescription.contains("authentication") {
                        self.addButtonOutlet.isEnabled = false
                        self.editButtonItem.isEnabled = false
                        self.removeApplePiles()
                        self.presentCloudErrorVC()
                    }
                }
            }
        }
    }
    
    func createFauxPiles() {
        if defaults.bool(forKey: "DidDeleteMultPile") == false {
            FlashpileController.shared.createMultPile { (result) in
                switch result {
                case .success(_):
                    self.collectionView.reloadData()
                case .failure(_):
                    print("no mult pile created")
                }
            }
        }
        if defaults.bool(forKey: "DidDeleteElementPile") == false {
            FlashpileController.shared.createElementPile { (result) in
                switch result {
                case .success(_):
                    self.collectionView.reloadData()
                case .failure(_):
                    print("no mult pile created")
                }
            }
        }
        if defaults.bool(forKey: "DidDeleteCapitalsPile") == false {
            FlashpileController.shared.createCapitalsPile { (result) in
                switch result {
                case .success(_):
                    self.collectionView.reloadData()
                case .failure(_):
                    print("no mult pile created")
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
        //return FlashpileController.shared.totalFlashpiles.count
        return FlashpileController.shared.totalFlashpiles.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? FlashpileCollectionViewCell else {return UICollectionViewCell()}
        
        let flashpile: Flashpile
        if isFiltering {
            flashpile = filteredFlashpiles[indexPath.row]
        } else {
            //flashpile = FlashpileController.shared.totalFlashpiles[indexPath.row]
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
            guard let index = FlashpileController.shared.totalFlashpiles.firstIndex(of: flashpileToDelete) else {return}
            let alertController = UIAlertController(title: "Delete", message: "Are you sure you want to delete the flashpile \"\(flashpileToDelete.subject)\" ?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                if !FlashpileController.shared.fauxFlashpileIDs.contains(flashpileToDelete.recordID) {
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
                } else {
                    if flashpileToDelete.subject == "Multiplication" {
                        FlashpileController.shared.totalFlashpiles.remove(at: index)
                        self.collectionView.reloadData()
                        self.defaults.set(true, forKey: "DidDeleteMultPile")
                    } else if flashpileToDelete.subject == "Periodic Table" {
                        FlashpileController.shared.totalFlashpiles.remove(at: index)
                        self.collectionView.reloadData()
                        self.defaults.set(true, forKey: "DidDeleteElementPile")
                    } else if flashpileToDelete.subject == "States and Capitals" {
                        FlashpileController.shared.totalFlashpiles.remove(at: index)
                        self.collectionView.reloadData()
                        self.defaults.set(true, forKey: "DidDeleteCapitalsPile")
                    }
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            self.present(alertController, animated: true)
        }
    }
} //End of Extension
