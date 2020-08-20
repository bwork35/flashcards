//
//  TableViewController.swift
//  flashcards
//
//  Created by Bryan Workman on 8/8/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import UIKit

class ElementTableViewController: UITableViewController {
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPeriodicTable()
    }
    
    //MARK: - Helper Methods
    func fetchPeriodicTable() {
        ElementController.fetchElements { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.tableView.reloadData()
                case .failure(let error):
                    print("TblVC error -- \(error) -- \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ElementController.shared.elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "elementCell", for: indexPath)
        
        let element = ElementController.shared.elements[indexPath.row]
        
        cell.textLabel?.text = element.name
        cell.detailTextLabel?.text = "\(element.atomicNumber) \(element.symbol)"

        return cell
    }
    
} //End class
