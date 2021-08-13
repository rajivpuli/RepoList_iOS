//
//  ContributorCell.swift
//  Repo List
//
//  Created by Rajiv Puli on 12/08/21.
//

import UIKit

class ContributorCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loadData(owner: ContributorsResponseModel) {
        avatar?.layer.cornerRadius = 27
        avatar?.clipsToBounds = true
        avatar?.loadThumbnail(urlSting: owner.avatarURL ?? "", placeHolder: imagePlaceHolder)
        nameLabel?.text = owner.login
    }

}
