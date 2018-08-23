//
//  ProfileViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 8/6/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var greenSkillsImage: UIImageView!
    
    @IBOutlet weak var profileRatingLabel: UILabel!
    @IBOutlet weak var profileGreenSkillsLabel: UILabel!
    @IBOutlet weak var profileRankingLabel: UILabel!
    @IBOutlet weak var profileAgeLabel: UILabel!
    @IBOutlet weak var profileLocationLabel: UILabel!
    
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var reviewTableView: UITableView!
    
    var user = User()
    var caddie = Caddie()
    var loop = Loop()
    var review = Review()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "\(user.firstName) \(user.lastName)"
        profileLocationLabel.text = "\(user.city), \(user.state)"
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        
        profileRatingLabel.text = String(caddie.rating)
        profileGreenSkillsLabel.text = String(caddie.greenSkills)
        
        reviewTableView.reloadData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        profileRatingLabel.text = String(caddie.rating)
        profileGreenSkillsLabel.text = String(caddie.greenSkills)
    }
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.caddie.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewcell") as! ProfileReviewTableViewCell
        let review = self.caddie.reviews[indexPath.row]
        cell.reviewCommentLabel.text = review.comment
        cell.reviewCreatedLabel.text = review.createdOn
        cell.reviewGreenSkillsLabel.text = String(review.greenSkills)
        cell.reviewRatingLabel.text = String(review.rating)

        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
