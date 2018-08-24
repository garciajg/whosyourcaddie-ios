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
import SkeletonView

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
    @IBOutlet weak var reviewTableView: UITableView! {
        didSet{
            reviewTableView.rowHeight = UITableViewAutomaticDimension
            reviewTableView.estimatedRowHeight = 200
        }
    }
    
    var user = User()
    var caddie = Caddie()
    var loop = Loop()
    var review = Review()
    var golfer = Golfer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "\(user.firstName) \(user.lastName)"
        profileLocationLabel.text = "\(user.city), \(user.state)"
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        
        reviewTableView.reloadData()
        setupSkeletonView()
        getUserProfileData()
        retrieveReviewData()

    }
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.caddie.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewcell") as! ProfileReviewTableViewCell
        let rev = self.caddie.reviews[indexPath.row]
//        let fmfDate = formatIncomingDate(dateString: rev.createdOn)
        cell.reviewCommentLabel.text = rev.comment
        cell.reviewCreatedLabel.text = rev.createdOn
        cell.reviewGreenSkillsLabel.text = String(rev.greenSkills)
        cell.reviewRatingLabel.text = String(rev.rating)
        cell.reviewNameLabel.text = rev.createdBy

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    
    //MARK: - Parsing JSON
    
    func getUserProfileData() {
        
        if user.userType == "CADDY" {
            
            let caddieURL = "http://0.0.0.0:8000/caddie/"
            let token = KeychainWrapper.standard.string(forKey: "token") as! String
            let headers : HTTPHeaders = [
                "Authorization":"Bearer \(token)",
                "Accept": "application/json"
            ]
            
            Alamofire.request(caddieURL, headers:headers).responseJSON { (respData) in
                switch respData.result {
                    
                case .success(let value):
                    let json = JSON(value)[0]
                    
                    let rating = json["rating"].double!
                    print("Caddie rating: \(json["rating"])")
                    let greenSkils = json["green_skills"].double!
                    let firstName = json["first_name"].string!
                    let lastName = json["last_name"].string!
                    let email = json["email"].string!
                    let state = json["state"].string!
                    let city = json["city"].string!
                    let zipcode = json["zipcode"].string!
                    let address = json["address"].string!
                    let phoneNumber = json["phone_number"].string!
                    let dateOfBirth = json["date_of_birth"].string!
                    let userType = json["user_type"].string!
                    let id = json["caddie_id"].int!
                    
                    for (_, id) in json["loops"]{
                        
                        self.loop.id = id.int!
                        
                        self.caddie.loops.append(self.loop)
                        
                    }
                    
                    self.caddie.id = id
                    self.caddie.address = address
                    self.caddie.city = city
                    self.caddie.dateOfBirth = dateOfBirth
                    self.caddie.email = email
                    self.caddie.firstName = firstName
                    self.caddie.lastName = lastName
                    self.caddie.phoneNumber = phoneNumber
                    self.caddie.state = state
                    self.caddie.zipcode = zipcode
                    self.caddie.userType = userType
                    self.caddie.rating = rating.rounded()
                    self.caddie.greenSkills = greenSkils.rounded()
                    
                    self.profileRatingLabel.text = String(rating)
                    self.profileGreenSkillsLabel.text = String(greenSkils)
                    
                    let age = self.getUserAge(birthDate: self.caddie.dateOfBirth)
                    self.caddie.age = age
                    
                    self.profileAgeLabel.text = String(age)
                    
                case .failure(let error):
                    
                    print(error)
                }
            }
        } else if user.userType == "GOLFR" {
            
        }
    }
    
    func retrieveReviewData() {
        let reviewURL = "http://0.0.0.0:8000/reviews"
        let token = KeychainWrapper.standard.string(forKey: "token") as! String
        let headers : HTTPHeaders = [
            "Authorization":"Bearer \(token)",
            "Accept": "application/json"
        ]
        
        
        Alamofire.request(reviewURL, headers: headers).responseJSON { (reviewData) in
            switch reviewData.result {
            case .success(let value):
                let json = JSON(value)
                for (_, dic) in json {
                    let rev = Review()
                    
                    print(dic["comment"])
                    rev.caddie = self.caddie
                    rev.id = dic["id"].int!
                    rev.createdOn = dic["created_on"].string!
                    rev.comment = dic["comment"].string!
                    rev.rating = (Double(dic["rating"].string!)?.rounded())!
                    rev.greenSkills = (Double(dic["green_skills"].string!)?.rounded())!
                    rev.id = dic["golfer"].int!
                    rev.createdBy = dic["created_by"].string!
                    rev.golfer = self.golfer
                    
                    self.caddie.reviews.append(rev)

                }
                self.reviewTableView.reloadData()
                self.removeSkeletonView()
                
            case .failure(let error):
                print(error)
            }
        
        }
        
    }
    
    //MARK: - Formating Date String
    
//    func formatIncomingDate(dateString:String) -> String {
//        let myFormatter = DateFormatter()
//        let tempLocale = myFormatter.locale
//        myFormatter.locale = Locale(identifier: "en_US_POSIX")
//        myFormatter.dateFormat = "yyyy-MM-ddTHH:mm:ss.SSSSSSZ"
//        print(dateString)
//        var dt = myFormatter.date(from:dateString)
//        print(dt)
//        myFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
//        myFormatter.locale = tempLocale // reset the locale
//        let dtString = myFormatter.string(from: dt!)
//        print("EXACT_DATE : \(dtString)")
//
//        return dtString
//    }
    
    
    //MARK: Get age from user
    
    func getUserAge(birthDate:String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.date(from: birthDate)
        let now = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: formattedDate!, to: now)
        let age = ageComponents.year!
        print(age)
        
        return age
    }
    
    //MARK: = SkeletonView Methods
    func setupSkeletonView() {
        for v in view.subviews {
            v.isSkeletonable = true
            v.showAnimatedGradientSkeleton()

        }
    }
    
    func removeSkeletonView() {
        for v in view.subviews {
            v.hideSkeleton()
        }
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
