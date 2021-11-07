//
//  DislikeViewController.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 31/10/2021.
//

import UIKit

protocol DislikeDelegate: AnyObject {
    func preferencesChosen(_ preferences: [String : Bool])
}

class DislikeViewController: UITableViewController {
    
    var chosenIndexes: [Int]!
    var preferences: [String : Bool] = [:]
    weak var delegate: DislikeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setPreferences(liked: true)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard !chosenIndexes.contains(indexPath.row) else { return false }
        return true
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if chosenIndexes.contains(indexPath.row){
            cell.backgroundColor = .lightGray
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        chosenIndexes.append(indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
        chosenIndexes = chosenIndexes.filter { $0 != indexPath.row }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let selectedRows = tableView.indexPathsForSelectedRows?.filter({ $0.section == indexPath.section }) {
            if selectedRows.count == 3 {
                return nil
            }
        }
        return indexPath
    }
    
    func setPreferences(liked: Bool){
        chosenIndexes.forEach {
            if let pref = Preferences(rawValue: $0){
                if !preferences.keys.contains("\(pref)") {
                    preferences["\(pref)"] = liked
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        setPreferences(liked: false)
        guard let destinationViewController = segue.destination as? ProfileTableViewController else { return }
        self.delegate = destinationViewController
        delegate?.preferencesChosen(self.preferences)
    }
}
