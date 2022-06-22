//
//  MessengerTableViewCell.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 07/11/2021.
//

import UIKit

class MessengerTableViewCell: UITableViewCell {

    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userView.layer.cornerRadius /= 4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
