//
//  HomeViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 7/20/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import SwiftKeychainWrapper
import SkeletonView

class HomeViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView! {
        didSet {
            profileImage.layer.borderWidth = 1
            profileImage.layer.masksToBounds = false
            profileImage.layer.borderColor = UIColor.black.cgColor
            profileImage.layer.cornerRadius = self.profileImage.frame.height/2
            profileImage.clipsToBounds = true
            profileImage.contentMode = .scaleAspectFill

        }
    }
    @IBOutlet weak var createLoopButton: UIButton!
    
    var user = User()
    var caddie = Caddie()
    var loop = Loop()
    var review = Review()
    var golfer = Golfer()
    var currentDayLoop = Loop()
    
    var isLoopTdy : Bool = false
    
    let CADDIE_URL = "http://0.0.0.0:8000/api/v1/caddie"
    let GOLFER_URL = "http://0.0.0.0:8000/api/v1/golfer"


    override func viewDidLoad() {
        super.viewDidLoad()
        showSkeletonView()
        welcomeLabel.text = "Welcome \(user.firstName)!"
        self.navigationItem.setHidesBackButton(true, animated: true)
        if user.userType == "CADDY" {
            getCaddieData(url: CADDIE_URL)
            createLoopButton.isEnabled = false
            createLoopButton.isHidden = true
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapLoopLabel(sender:)))
            welcomeLabel.addGestureRecognizer(gesture)
            
            getProfilePicture { (profImage) in
                
                //            self.profileImage.image = profImage
                //            self.profileImage.contentMode = .scaleAspectFill
                self.caddie.profImg = profImage
                self.profileImage.image = self.caddie.profImg
                
            }
            
        } else if user.userType == "GOLFR" {
            getGolferData(url: GOLFER_URL)
            getProfilePicture { (profImage) in
                
                //            self.profileImage.image = profImage
                //            self.profileImage.contentMode = .scaleAspectFill
                self.golfer.profImg = profImage
                self.profileImage.image = self.golfer.profImg

            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.user.userType == "CADDY" {
            getCaddieData(url: CADDIE_URL)
        }
    }

    @IBAction func didTapViewProfile(_ sender: Any) {
        self.performSegue(withIdentifier: "profilesegue", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "profilesegue" {
            let vc = segue.destination as! ProfileViewController
            vc.user = self.user
            vc.loop = self.loop
            vc.review = self.review
            vc.profileImage = self.profileImage

            if self.user.userType == "CADDY"{
                vc.caddie = self.caddie

            } else if self.user.userType == "GOLFR" {
                vc.golfer = self.golfer
            }
        } else if segue.identifier == "courseviewsegue" {
            let vc = segue.destination as! CourseViewController
            vc.golfer = self.golfer
        } else if segue.identifier == "loopdetailsegue" {
            let vc = segue.destination as! LoopDetailViewController
            vc.loop = self.currentDayLoop
            vc.caddie = self.caddie
        }
    }
    
    func getCaddieData(url:String) {
        
        let headers = authHeaders()
        
        Alamofire.request(url, headers: headers).validate(statusCode: 200...299).responseJSON { (caddieData) in
            switch caddieData.result {
            case .success(let value):
                
                let json = JSON(value)[0]
                self.caddie.greenSkills = json["green_skills"].double!
                self.caddie.rating = json["rating"].double!
                self.caddie.caddieID = json["caddie_id"].int!
                
                for (_, id) in json["loops"] {
                    
                    self.retrieveLoopData(id: id.int!)
                }
                
                self.hideSkeletonView()
                
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func getGolferData(url:String) {
        
        let headers = authHeaders()
        
        Alamofire.request(url, headers: headers).validate(statusCode: 200...299).responseJSON { (caddieData) in
            switch caddieData.result {
            case .success(let value):
                
                let json = JSON(value)[0]
                self.golfer.golferID = json["golfer_id"].int!
                
                for (_, id) in json["loops"] {
                    
                    self.retrieveLoopData(id: id.int!)
                }
                
                self.hideSkeletonView()
                
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func getProfilePicture(completion: @escaping (UIImage) -> Void) {
        let imageURL = user.profilePicture
        print(imageURL)
        Alamofire.request(imageURL, method: .get).responseImage { response in
            guard let image = response.result.value else {
                // Handle error
                return
            }
            // Do stuff with your image
            completion(image)
        }
    }
    
    //MARK: Retireve Loop Data
    func retrieveLoopData(id:Int) {
        let LOOP_URL = "http://0.0.0.0:8000/api/v1/loops/\(id)"
        
        let headers = authHeaders()
        let lp = Loop()
        
        Alamofire.request(LOOP_URL, headers: headers).validate(statusCode: 200...299).responseJSON { (loopData) in
            switch loopData.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                lp.accepted = json["accepted"].bool!
                lp.cancelled = json["cancelled"].bool!
                lp.loopDate = json["loop_date"].string!
                lp.id = id
                lp.isWalking = json["is_walking"].bool!
                lp.startTime = json["start_time"].string!
                lp.numberOfHoles = json["number_of_holes"].string!
                
                let course = self.getCourse(id: json["course"].int!)
                lp.course = course
                
                let lpMir = Mirror(reflecting: lp)
                
                print(self.user.userType)
                
                if self.user.userType == "CADDY" {
                    lp.caddie = self.caddie

                    let golfr = self.getGofler(id: json["golfer"].int!)
                    lp.golfer = golfr
                    for (n, v) in lpMir.children {
                        guard let n = n else {continue}
                        print(n, v)
                    }
                    self.caddie.loops.append(lp)
                    let loopTime = self.formatedTime(timeString: lp.startTime)
                    if self.isLoopToday(dateAsString: lp.loopDate) == true {
                        let loopRemiderMessage = "Seems like you have loop today at \(loopTime). Touch here to see the details."
                        self.welcomeLabel.text = loopRemiderMessage
                        self.currentDayLoop = lp
                        self.isLoopTdy = true
                        
                    } else if self.isLoopToday(dateAsString: lp.loopDate) == false {
//                        self.welcomeLabel.isUserInteractionEnabled = false
                        print("sorry")
                    }
                    
                    if self.isLoopTdy == true {
                        self.welcomeLabel.isUserInteractionEnabled = true
                    }
                    if self.caddie.loops.count < 1 {
                        self.welcomeLabel.text = "Hey \(self.caddie.firstName), seems like you have no loops. Just be patient."
                    }
                } else if self.user.userType == "GOLFR" {
                    lp.golfer = self.golfer
                    lp.caddie?.caddieID = json["caddie"].int!
                    self.golfer.loops.append(lp)
                     let loopTime = self.formatedTime(timeString: lp.startTime)
                    if self.isLoopToday(dateAsString: lp.loopDate) == true {
                        let loopReminderMessage = "Seems like you're playing today at \(loopTime). Good luck and have fun!"
                        self.welcomeLabel.text = loopReminderMessage
                    }
                    
                }
                
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    //MARK: Headers for Authentication
    public func authHeaders() -> HTTPHeaders {
        let token = KeychainWrapper.standard.string(forKey: "token")
        let headers : HTTPHeaders = [
            "Authorization":"Bearer \(token!)",
            "Accept": "application/json"
        ]
        
        return headers
    }
    
    //MARK: SkeletonView show and hide methods
    public func showSkeletonView() {
        for v in view.subviews {
            v.isSkeletonable = true
            v.showAnimatedGradientSkeleton()
        }
    }
    
    public func hideSkeletonView() {
        for v in view.subviews {
            v.hideSkeleton()
        }
    }
    
    public func presentAlert(title:String, message:String) {
        
        let alert = UIAlertController(title: title, message:message , preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    func isLoopToday(dateAsString:String) -> Bool{
        
        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "yyyy-MM-dd"
        let dt = myFormatter.date(from:dateAsString)
        let now = Date()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: now, to: dt!)
       
        if components.day == 0 {
            return true
        }
        
        return false
    }
    
//    func getCaddie(id:Int) -> Caddie {
//
//        let CADDIE_URL = "http://0.0.0.0:8000/api/v1/caddie/\(id)"
//        Alamofire.request(CADDIE_URL, method: <#T##HTTPMethod#>, parameters: <#T##Parameters?#>, encoding: <#T##ParameterEncoding#>, headers: <#T##HTTPHeaders?#>)
//    }
    
    func getGofler(id:Int) -> Golfer {
        
        let GOLFER_URL = "http://0.0.0.0:8000/api/v1/golfer/\(id)"
        let headers = authHeaders()
        let golfr = Golfer()
        Alamofire.request(GOLFER_URL, method: .get, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200...299).responseData { (golferData) in
            switch golferData.result{
            case .success(let value):
                let json = JSON(value)
                print(json)
                golfr.golferID = json["golfer_id"].int!
                golfr.firstName = json["first_name"].string!
                golfr.lastName = json["last_name"].string!
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        return golfr
    }
    
    func getCourse(id:Int) -> Course {
        
        let COURSE_URL = "http://0.0.0.0:8000/api/v1/courses/\(id)"
        let headers = authHeaders()
        let course = Course()
        
        Alamofire.request(COURSE_URL, method: .get, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200...299).responseData { (courseData) in
            switch courseData.result {
            case .success(let value):
                let json = JSON(value)
                
                
                course.latitude = json["latitude"].float!
                course.longitude = json["longitude"].float!
                course.id = json["id"].int!
                course.name = json["course_name"].string!
                
                
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        return course
    }
    
    @objc func didTapLoopLabel(sender: UITapGestureRecognizer) {
        if isLoopTdy == true {
            print("I've been touched")
            performSegue(withIdentifier: "loopdetailsegue", sender: self)
        }
    }
    
    func formatedTime(timeString:String) -> String {
        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "HH:mm:ss"
        let d = myFormatter.date(from: timeString)
        myFormatter.timeStyle = .short
        let time = myFormatter.string(from: d!)
        
        return time
        
    }
    
    @IBAction func unwindsToHomeViewController(segue:UIStoryboardSegue) {
        let vc = segue.source as! LoopDetailViewController
        vc.caddie = caddie
        getCaddieData(url: CADDIE_URL)
    }
    
    
}
