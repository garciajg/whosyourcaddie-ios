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
    
    var cell : ProfileReviewTableViewCell!
    
    var user = User()
    var caddie = Caddie()
    var loop = Loop()
    var review = Review()
    var golfer = Golfer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "\(user.firstName) \(user.lastName)"
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        
        profileLocationLabel.numberOfLines = 1
        profileLocationLabel.adjustsFontSizeToFitWidth = true
        
        let rightButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(self.logout(sender:)))
        
        self.navigationItem.rightBarButtonItem = rightButton
        
        reviewTableView.reloadData()
        setupSkeletonView()
        getUserProfileData()
        getProfilePicture()
        retrieveReviewData()

    }
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.caddie.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewcell") as! ProfileReviewTableViewCell
        let rev = self.caddie.reviews[indexPath.row]
        cell.reviewCommentLabel.text = rev.comment
        cell.reviewCreatedLabel.text = rev.createdOn
        cell.reviewGreenSkillsLabel.text = String(format: "%.2f", rev.greenSkills)
        cell.reviewRatingLabel.text = String(format: "%.2f", rev.rating)
        cell.reviewNameLabel.text = rev.createdBy

        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Reviews"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    
    //MARK: - Parsing JSON
    
    func getUserProfileData() {
        
        if user.userType == "CADDY" {
            
            let caddieURL = "http://0.0.0.0:8000/api/v1/caddie/"
            let headers = authHeaders()
            
            Alamofire.request(caddieURL, headers:headers).responseJSON { (respData) in
                switch respData.result {
                    
                case .success(let value):
                    let json = JSON(value)[0]
                    
                    let rating = json["rating"].double!
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
                        let loop = Loop()
                        loop.id = id.int!
                        
                        self.caddie.loops.append(loop)
                        
                    }
                    
                    self.caddie.caddieID = id
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
                    self.caddie.rating = rating
                    self.caddie.greenSkills = greenSkils
                    
                    self.profileRatingLabel.text = String(format: "%.2f", rating)
                    self.profileGreenSkillsLabel.text = String(format: "%.2f", greenSkils)
                    
                    let age = self.getUserAge(birthDate: self.caddie.dateOfBirth)
                    self.caddie.age = age
                    
                    self.profileAgeLabel.text = "Age: \(age)"
                    self.profileLocationLabel.text = "From: \(city), \(state)"
                    
                case .failure(let error):
                    
                    print(error)
                }
            }
        } else if user.userType == "GOLFR" {
            let golferURL = "http://0.0.0.0:8000/api/v1/golfer/"
            let headers = authHeaders()
            
            Alamofire.request(golferURL, headers:headers).responseJSON { (respData) in
                
                switch respData.result {
                    
                case .success(let value):
                    let json = JSON(value)[0]
                    
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
                    let id = json["golfer_id"].int!
                    
                    for (_, id) in json["loops"]{
                        let loop = Loop()
                        loop.id = id.int!
                        
                        self.golfer.loops.append(loop)
                        
                    }
                    
                    self.golfer.golferID = id
                    self.golfer.address = address
                    self.golfer.city = city
                    self.golfer.dateOfBirth = dateOfBirth
                    self.golfer.email = email
                    self.golfer.firstName = firstName
                    self.golfer.lastName = lastName
                    self.golfer.phoneNumber = phoneNumber
                    self.golfer.state = state
                    self.golfer.zipcode = zipcode
                    self.golfer.userType = userType
                    
                    self.profileRatingLabel.isHidden = true
                    self.profileGreenSkillsLabel.isHidden = true
                    
                    let age = self.getUserAge(birthDate: self.golfer.dateOfBirth)
                    self.golfer.age = age
                    
                    self.profileAgeLabel.text = "Age: \(age)"
                    
                    self.profileLocationLabel.text = "From: \(city), \(state)"
                    
                case .failure(let error):
                    
                    print(error)
                }
            }
        }
    }
    
    func getProfilePicture() {
        let imageURL = user.profilePicture
        
        Alamofire.request(imageURL, method: .get).responseImage { response in
            guard let image = response.result.value else {
                // Handle error
                return
            }
            // Do stuff with your image
            self.profileImage.image = image
            self.profileImage.layer.borderWidth = 1
            self.profileImage.layer.masksToBounds = false
            self.profileImage.layer.borderColor = UIColor.black.cgColor
            self.profileImage.layer.cornerRadius = self.profileImage.frame.height/2
            self.profileImage.clipsToBounds = true
        }
    }
    
    
    func retrieveReviewData() {
        let reviewURL = "http://0.0.0.0:8000/api/v1/reviews"
        let headers = authHeaders()
        var reviewsArray: [Review] = []
        
        
        Alamofire.request(reviewURL, headers: headers).responseJSON { (reviewData) in
            switch reviewData.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                for (_, dic) in json {
                    let rev = Review()
                    
                    rev.caddie = self.caddie
                    rev.id = dic["id"].int!
                    rev.comment = dic["comment"].string!
                    rev.rating = Double(dic["rating"].string!)!
                    rev.greenSkills = Double(dic["green_skills"].string!)!
//                    rev.id = dic["golfer"].int!
                    rev.createdBy = dic["created_by"].string!
                    rev.golfer = self.golfer
                    let created = self.formatIncomingDate(dateString: dic["created_on"].string!)
                    rev.createdOn = created
                    
                    
                    reviewsArray.append(rev)
                    
                }
                self.caddie.reviews = reviewsArray
                self.reviewTableView.reloadData()
                self.removeSkeletonView()
                
            case .failure(let error):
                print(error)
            }
            
        }
        
    }
    
    //MARK: - Formating Date String
    
    func formatIncomingDate(dateString:String) -> String {
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dt = dateFormatter.date(from: dateString)!
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy" ; //"dd-MM-yyyy HH:mm:ss"
        dateFormatter.locale = tempLocale // reset the locale --> but no need here
        let dateStr = dateFormatter.string(from: dt)
       
        return dateStr
    }
    
    //MARK: Headers for Authentication
    func authHeaders() -> HTTPHeaders {
        let token = KeychainWrapper.standard.string(forKey: "token") as! String
        let headers : HTTPHeaders = [
            "Authorization":"Bearer \(token)",
            "Accept": "application/json"
        ]

        return headers
    }
    
    
    //MARK: Get age from user
    
    func getUserAge(birthDate:String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.date(from: birthDate)
        let now = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: formattedDate!, to: now)
        let age = ageComponents.year!
        
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
    
    func presentAlert(title:String, message:String) {
        
        let alert = UIAlertController(title: title, message:message , preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Actions

    @IBAction func didPressEditProfile(_ sender: Any) {
        
        performSegue(withIdentifier: "editprofilesegue", sender: self)
        
    }
    
    @IBAction func logout(sender:Any){
        Alamofire.SessionManager.default.session.reset {
            let alert = UIAlertController(title: "Logged out", message: "You have been logged out.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                _ = KeychainWrapper.standard.removeAllKeys()
                self.performSegue(withIdentifier: "unwindToSignIn", sender: self)
                
            })
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
        

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "editprofilesegue" {
            let vc = segue.destination as! EditProfileViewController
            vc.caddie = self.caddie
            vc.golfer = self.golfer
            vc.user = self.user
        }
    }
    
    func caddieLoopDetails() {
        editProfileButton.setTitle("Request \(caddie.firstName)", for: .normal)
        
    }
}
