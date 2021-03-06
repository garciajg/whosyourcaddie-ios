//
//  AvailableCaddiesViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 8/29/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper
import SwiftyJSON
import SkeletonView
import Lottie

class AvailableCaddiesTableViewController: UITableViewController {//}, SkeletonTableViewDataSource {
    
    var golfer = Golfer()
    var caddie = Caddie()
    var caddiesArray : [Caddie] = []
    var loop = Loop()
    var localTimeZone : String {return TimeZone.current.identifier}
    
    let animationView = LOTAnimationView(name: "loading_animation")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        getAllAvailableCaddies()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return caddiesArray.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 112
        return 112
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loop.caddie = caddiesArray[indexPath.row]
        let caddieName = "\(loop.caddie?.firstName as! String) \(loop.caddie?.lastName as! String)"
        let courseName = loop.course?.name as! String
        let time = formatedTime(timeString: loop.startTime)
        let date = formattedDate(dateString: loop.loopDate)
        let message = """
        Caddie: \(caddieName)
        Course: \(courseName)
        Time: \(date) at \(time)
        """
        
        let alert = UIAlertController(title: "Confirm Loop", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            self.postLoopData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
        
        

//        performSegue(withIdentifier: "caddiedetailsegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "caddielist") as! CaddieListTableViewCell
        let caddy = caddiesArray[indexPath.row]
        let roundedRating = String(format: "%.2f", caddy.rating)
        let roundedGreenS = String(format: "%.2f", caddy.greenSkills)
        cell.greenSkillsLabel.text = roundedGreenS
        cell.ratingLabel.text = roundedRating
        cell.rankingLabel.text = caddy.ranking
        cell.nameLabel.text = "\(caddy.firstName) \(caddy.lastName)"
        cell.locationLabel.text = "\(caddy.city), \(caddy.state)"
        cell.caddiePhoto.image = caddy.profImg
        
        return cell
    }
    
    
    func getAllAvailableCaddies() {
        let headers = authHeaders()
        let caddiesURL = "http://0.0.0.0:8000/api/v1/caddie"
        
        Alamofire.request(caddiesURL, method: .get, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200...299).responseData { (caddiesData) in
            switch caddiesData.result {
            case .success(let value):
                let json = JSON(value)
                for (_, caddie) in json {
                    let caddy = Caddie()
                    
                    caddy.firstName = caddie["first_name"].string!
                    caddy.lastName = caddie["last_name"].string!
                    caddy.rating = caddie["rating"].double!
                    caddy.greenSkills = caddie["green_skills"].double!
                    caddy.state = caddie["state"].string!
                    caddy.city = caddie["city"].string!
                    caddy.caddieID = caddie["caddie_id"].int!
                    let ranking = self.formatRanking(ranking: caddie["ranking"].string!)
                    caddy.ranking = ranking

                    self.getProfilePictureForReviews(from: caddie["profile_image"].url!, completion: { (profImg) in
                        caddy.profImg = profImg
                        self.tableView.reloadData()
                    })
                    
                    self.caddiesArray.append(caddy)
                }
            self.tableView.reloadData()
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
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
    
    
    func postLoopData() {
        
        animationView.isHidden = false
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundColor = .gray
        animationView.layer.cornerRadius = animationView.frame.size.height / 8
        animationView.clipsToBounds = true
        view.addSubview(animationView)
        animationView.loopAnimation = true
        animationView.animationSpeed = 1.5
        
        animationView.play()
        
        let parameters = [
            "start_time":loop.startTime,
            "loop_date":loop.loopDate,
            "golfer":golfer.golferID,
            "caddie":loop.caddie?.caddieID ?? 0,
            "is_walking":loop.isWalking,
            "number_of_holes":loop.numberOfHoles,
            "course":loop.course?.id ?? 0,
            "timezne":localTimeZone
            ] as [String : Any]
        
        print(parameters)
        
        let headers = authHeaders()
        
        
        Alamofire.request("http://0.0.0.0:8000/api/v1/loops", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200...299).responseData { (loopData) in
            switch loopData.result {
                
            case .success(let value):
                let json = JSON(value)
                print(json)
                self.animationView.stop()
                self.animationView.isHidden = true
                
                
            case .failure(let error):
                
                self.animationView.stop()
                self.animationView.isHidden = true

                if loopData.response?.statusCode == 400 {
                    let alert = UIAlertController(title: "Sorry!",
                                                  message: "Loops cannot be created less than 30 minutes from the loop time.",
                                                  preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
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
    
    func formattedDate(dateString:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString)
        dateFormatter.dateStyle = .medium
        let dateStr = dateFormatter.string(from: date!)
        
        return dateStr

        
    }
    
    
    //MARK: - Format Ranking
    func formatRanking(ranking:String) -> String {
        if ranking == "BCADDY" {
            return "B Caddie"
        } else if ranking == "ACADDY" {
            return "A Caddie"
        } else {
            return "Honor"
        }
    }
    

     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
        if let cell = sender as? CaddieListTableViewCell {
            let i = self.tableView.indexPath(for: cell)!.row
            if segue.identifier == "caddiedetailsegue"{
                let vc = segue.destination as! CaddieDetailViewController
                let caddy = self.caddiesArray[i] 
                print(caddy.firstName)
                vc.caddie = caddy
                vc.loop = self.loop
                vc.golfer = self.golfer
            }
        }
     }
    
    
    //MARK: - Get caddies profiles pictures
    func getProfilePictureForReviews(from imageURL:URL, completion: @escaping (UIImage) -> Void) {
        print(imageURL)
        
        Alamofire.request(imageURL).responseImage { (response) in
            if let image = response.result.value {
                
                completion(image)
            } else {
                let alert = UIAlertController(title: "Error",
                                              message: "There has been an error while downloading your profile picture.",
                                              preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }


    
}
