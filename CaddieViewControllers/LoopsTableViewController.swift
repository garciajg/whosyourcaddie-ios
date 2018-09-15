//
//  LoopsTableViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 9/10/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

class LoopsTableViewController: UITableViewController {
    
    var caddie = Caddie()
    var golfer = Golfer()
    var pastLoops : [Loop] = []
    var upcommingLoops : [Loop] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        retrieveLoops()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Upcoming Loops"
        } else {
            return "Past Loops"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return upcommingLoops.count
        } else {
            return pastLoops.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "allloopscell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! LoopsTableViewCell
        if indexPath.section == 0{
            let lp = upcommingLoops[indexPath.row]
            cell.courseNameLabel.text = lp.course?.name
            cell.dateLabel.text = formattedDate(dateString: lp.loopDate)
            cell.timeLabel.text = formatedTime(timeString: lp.startTime)
            cell.userLabel.text = "\(lp.golfer?.firstName) \(lp.golfer?.lastName)"
            if lp.numberOfHoles == "NINE" {
                cell.numberOfHolesLabel.text = "9 Holes"
            } else {
                cell.numberOfHolesLabel.text = "18 Holes"
            }
            if lp.isWalking == true {
                cell.walkingLabel.text = "Walking Loop"
            } else {
                cell.walkingLabel.text = "Forecadding Loop"
            }
            
        } else {
            let lp = pastLoops[indexPath.row]
            cell.courseNameLabel.text = lp.course?.name
            cell.dateLabel.text = formattedDate(dateString: lp.loopDate)
            cell.timeLabel.text = formatedTime(timeString: lp.startTime)
            cell.userLabel.text = "\(lp.golfer?.firstName) \(lp.golfer?.lastName)"
            if lp.numberOfHoles == "NINE" {
                cell.numberOfHolesLabel.text = "9 Holes"
            } else {
                cell.numberOfHolesLabel.text = "18 Holes"
            }
            if lp.isWalking == true {
                cell.walkingLabel.text = "Walking Loop"
            } else {
                cell.walkingLabel.text = "Forecadding Loop"
            }
            
        }

        // Configure the cell...

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func retrieveLoops() {
        let LOOPS_URL = "http://0.0.0.0:8000/api/v1/loops"
        let headers = authHeaders()
        let lp = Loop()
        
        Alamofire.request(LOOPS_URL, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200...299).responseData { (loopsData) in
            switch loopsData.result{
            case .success(let value):
                let json = JSON(value)
                for (_, loop) in json {
                    print(loop)
                    let stTime = loop["start_time"].string!
                    let lpDate = loop["loop_date"].string!
                    
                    self.getCourse(id: loop["course"].int!, completion: { (course) in
                        lp.course = course
                        self.tableView.reloadData()
                    })
                    self.getGofler(id: loop["golfer"].int!, completion: { (golfer) in
                        lp.golfer = golfer
                        self.tableView.reloadData()
                    })
                    let caddy = self.caddie
                    let id = loop["id"].int!
                    let cancelled = loop["cancelled"].bool!
                    let isWalking = loop["is_walking"].bool!
                    let accepted = loop["accepted"].bool!
                    let numberOfHoles = loop["number_of_holes"].string!
                    
                    lp.id = id
                    lp.startTime = stTime
                    lp.loopDate = lpDate
//                    lp.golfer = golfr
                    lp.caddie = caddy
//                    lp.course = course
                    lp.cancelled = cancelled
                    lp.isWalking = isWalking
                    lp.accepted = accepted
                    lp.numberOfHoles = numberOfHoles
                    
                    
                    let fullDate = self.formattedFullDate(dateString: lpDate,
                                                      timeString: stTime)
                    if self.isLoopInThePast(date: fullDate) == true {
                        self.pastLoops.append(lp)
                    } else {
                        self.upcommingLoops.append(lp)
                    }
                    
                }
                
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    func authHeaders() -> HTTPHeaders {
        let token = KeychainWrapper.standard.string(forKey: "token")
        let headers : HTTPHeaders = [
            "Authorization":"Bearer \(token!)",
            "Accept": "application/json"
        ]
        
        return headers
    }
    
    //MARK: - Date Methods
    
    func isLoopInThePast(date:Date) -> Bool {
        
        if date < Date() {
            return true
        }
        
        return false
    }
    
    func formattedFullDate(dateString:String, timeString:String) -> Date {
        
        let fullDate = "\(dateString) \(timeString)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: fullDate)
        
        return date!
        
    }
    
    func formattedDate(dateString:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat="yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString)
        dateFormatter.dateStyle = .medium
        let dateStr = dateFormatter.string(from: date!)
        
        return dateStr
    }
    
    
    
    func formatedTime(timeString:String) -> String {
        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "HH:mm:ss"
        let d = myFormatter.date(from: timeString)
        myFormatter.timeStyle = .short
        let time = myFormatter.string(from: d!)
        
        return time
        
    }
    
    //MARK: - Get Models
    
    func getGofler(id:Int, completion: @escaping (Golfer?) -> Void )  {
        
        let GOLFER_URL = "http://0.0.0.0:8000/api/v1/golfer/\(id)"
        let headers = authHeaders()
        let golfr = Golfer()
        Alamofire.request(GOLFER_URL, headers: headers).validate(statusCode: 200...299).responseData { (golferData) in
            switch golferData.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                
                golfr.firstName = json["first_name"].string!
                golfr.lastName = json["last_name"].string!
                golfr.golferID = json["golfer_id"].int!
                
                completion(golfr)
            
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

    }
    
    func getCourse(id:Int, completion: @escaping (Course) -> Void) {
        
        let COURSE_URL = "http://0.0.0.0:8000/api/v1/courses/\(id)"
        let headers = authHeaders()
        let course = Course()
        
        Alamofire.request(COURSE_URL, headers: headers).validate(statusCode: 200...299).responseData { (courseData) in
            switch courseData.result{
            case .success(let value):
                let json = JSON(value)
                print(json)
                
                course.id = json["id"].int!
                course.latitude = json["latitude"].float!
                course.longitude = json["longitude"].float!
                course.name = json["course_name"].string!
                
                completion(course)
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }

}
