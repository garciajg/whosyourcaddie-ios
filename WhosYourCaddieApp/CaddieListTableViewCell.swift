//
//  CaddieListTableViewCell.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 7/18/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit

class CaddieListTableViewCell: UITableViewCell {
    @IBOutlet weak var caddiePhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var greenSkillsLabel: UILabel!
    @IBOutlet weak var rankingLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationPicture: UIImageView!
    @IBOutlet weak var greenSPicture: UIImageView!
    @IBOutlet weak var ratingPicture: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
