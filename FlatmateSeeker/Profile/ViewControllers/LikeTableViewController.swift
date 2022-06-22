//
//  LikeTableViewController.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 31/10/2021.
//

import UIKit

class LikeTableViewController: UITableViewController {
    
    var chosenIndices: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        chosenIndices.append(indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
        chosenIndices = chosenIndices.filter { $0 != indexPath.row }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let selectedRows = tableView.indexPathsForSelectedRows?.filter({ $0.section == indexPath.section }) {
            if selectedRows.count == 3 {
                return nil
            }
        }
        return indexPath
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dislikeVC = segue.destination as! DislikeViewController
        dislikeVC.chosenIndexes = self.chosenIndices
    }
}
