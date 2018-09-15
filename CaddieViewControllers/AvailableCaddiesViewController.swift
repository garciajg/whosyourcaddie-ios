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

class AvailableCaddiesTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource{//}, SkeletonTableViewDataSource {
    
    var golfer = Golfer()
    var caddie = Caddie()
    var caddiesArray : [Caddie] = []
    var loop = Loop()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return caddiesArray.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "caddielist") as! CaddieListTableViewCell
        
        return cell
    }
    
    
    func getAllAvailableCaddies() {
        let headers = authHeaders()
        let caddiesURL = "http://0.0.0.0:8000/caddie"
        
        Alamofire.request(caddiesURL, method: .get, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200...299).responseData { (caddiesData) in
            switch caddiesData.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                
            case .failure(let error):
                print(error)
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
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
