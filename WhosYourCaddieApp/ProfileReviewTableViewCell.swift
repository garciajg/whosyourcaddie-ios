//
//  ProfileReviewTableViewCell.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 8/6/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit

class ProfileReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reviewProfileImage: UIImageView!
    @IBOutlet weak var reviewRatingImage: UIImageView!
    @IBOutlet weak var reviewGreenSkillsImage: UIImageView!
    
    @IBOutlet weak var reviewNameLabel: UILabel!
    @IBOutlet weak var reviewRatingLabel: UILabel!
    @IBOutlet weak var reviewGreenSkillsLabel: UILabel!
    @IBOutlet weak var reviewCreatedLabel: UILabel!
    @IBOutlet weak var reviewCommentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
