//
//  MessengerTableViewController.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 07/11/2021.
//

import UIKit
import ProgressHUD
import Firebase

class MessengerTableViewController: UITableViewController {
    
    private var users : [User] = []
    private var imagesArray: [String : UIImage] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ProgressHUD.show()
        tableView.register(UINib(nibName: "MessengerTableViewCell", bundle: nil), forCellReuseIdentifier: "MessengerTableViewCell")
        FirestoreListener.sharedInstance.getCurrentUserMatches { users in
            guard let users = users else {
                return
            }
            self.users = users
            self.downloadImagesOfUsers(users: users, {
                self.tableView.reloadData()
                ProgressHUD.dismiss()
            })
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count == 0 ? tableView.setEmptyMessage("You don't have any matches yet!") : tableView.restore()
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessengerTableViewCell", for: indexPath) as! MessengerTableViewCell
        cell.nameLabel.text = users[indexPath.row].name
        cell.userImage.image = imagesArray.isEmpty ? UIImage(named: "emptyImage") : imagesArray[users[indexPath.row].id]
        return cell
    }
    
    func downloadImagesOfUsers(users: [User], _ completion: @escaping () -> ()) {
        let myGroup = DispatchGroup()
        users.forEach {
            myGroup.enter()
            FirestoreListener.sharedInstance.getFromCloudWithId(id: $0.id) { image, id in
                ProgressHUD.show()
                self.imagesArray[id] = image ?? UIImage(named: "emptyImage")!
                myGroup.leave()
            }
        }
        myGroup.notify(queue: .main) {
            completion()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ProgressHUD.show()
        let vc = MessengerViewController()
        guard let id = Auth.auth().currentUser?.uid else { return }
        FirestoreListener.sharedInstance.downloadExistingUserFromFirestore(id: users[indexPath.row].id) { user in
            guard let matchedUser = user else { return }
            FirestoreListener.sharedInstance.downloadExistingUserFromFirestore(id: id) { user in
                guard let currentUser = user else { return }
                vc.title = matchedUser.name
                vc.currentUser = Sender(senderId: id, displayName: currentUser.name)
                vc.reciever = Sender(senderId: matchedUser.id, displayName: matchedUser.name)
                vc.recieverId = matchedUser.id
                vc.messagesId = [id,matchedUser.id].sorted(by: <).joined()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
