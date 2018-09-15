//
//  LoopDetailViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 9/6/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

class LoopDetailViewController: UIViewController, MKMapViewDelegate {
    
    var loop = Loop()
    var caddie = Caddie()
    var golfer = Golfer()

    @IBOutlet weak var loopDetailLabel: UILabel!
    @IBOutlet weak var loopCourseMapView: MKMapView!
    @IBOutlet weak var cancelLoopButton: UIButton!
    @IBOutlet weak var courseMapView: MKMapView!
    
    let courseLocation = MKPointAnnotation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loopTime = formatedTime(timeString: loop.startTime)
        loopDetailLabel.numberOfLines = 0
        self.cancelLoopButton.layer.cornerRadius = self.cancelLoopButton.frame.size.height / 2
        self.cancelLoopButton.clipsToBounds = true


        if loop.accepted == true {
            
            
            let message = """
            Your loop is at \(loopTime) today with \(loop.golfer?.firstName as! String) \(loop.golfer?.lastName as! String). \n
            It will be at \(loop.course?.name as! String). Make sure you arrive at least 15 minutes early for warm up. Have fun!
            """
            loopDetailLabel.text = message
            self.cancelLoopButton.setTitle("Cancel Loop", for: .normal)
        } else if loop.accepted == false {
            let message = """
            Your loop is at \(loopTime) today with \(loop.golfer?.firstName as! String) \(loop.golfer?.lastName as! String). \n
            It will be at \(loop.course?.name as! String). Make sure you arrive at least 15 minutes early for warm up. Have fun!
            """
            loopDetailLabel.text = message
            self.cancelLoopButton.setTitle("Accept Loop", for: .normal)
            self.cancelLoopButton.setTitleColor(UIColor.white, for: .normal)
            self.cancelLoopButton.backgroundColor = UIColor(red: 46/255, green: 175/255, blue: 1, alpha: 1)
        }
        
        let rightButton = UIBarButtonItem(title: "All Loops",
                                          style: .plain,
                                          target: self,
                                          action: #selector(seeAllLoops))
        
        self.navigationItem.rightBarButtonItem = rightButton

        courseMapView.delegate = self
        
        let course = loop.course
        let latitude = Double((course?.latitude)!)
        let longitude = Double((course?.longitude)!)
        let courseCoordinates = CLLocation(latitude: latitude, longitude: longitude)
        centerMapOnCourse(course: courseCoordinates)

        courseLocation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        courseLocation.title = course?.name as! String
        courseMapView.addAnnotation(courseLocation)
        
    }
    
    func centerMapOnCourse(course:CLLocation) {
        let regionRadious : CLLocationDistance = 2500
        let courseRegion = MKCoordinateRegionMakeWithDistance(course.coordinate, regionRadious, regionRadious)
        courseMapView.setRegion(courseRegion, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        }
        let pinImage = #imageLiteral(resourceName: "greenskillspicture")
        let size = CGSize(width: 35, height: 35)
        UIGraphicsBeginImageContext(size)
        pinImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(#imageLiteral(resourceName: "checkmark"), for: .normal)
        button.addTarget(self, action:#selector(self.selectedCourse), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        pinView?.image = resizedImage
        
        return pinView
    }
    
    @objc func selectedCourse(){
        
        let currentLocMapItem = MKMapItem.forCurrentLocation()
        
        let selectedPlacemark = MKPlacemark(coordinate: courseLocation.coordinate, addressDictionary: nil)
        let selectedMapItem = MKMapItem(placemark: selectedPlacemark)
        
        let mapItems = [currentLocMapItem, selectedMapItem]
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        MKMapItem.openMaps(with: mapItems, launchOptions:launchOptions)
        
    }
    
    @IBAction func didPressCancelLoop(_ sender: Any) {
        if loop.accepted == true {
            self.cancelLoop()
        } else if loop.accepted == false {
            self.acceptLoop()
        }
    }
    
    


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "allloopssegue" {
            let vc = segue.destination as! LoopsTableViewController
            vc.caddie = self.caddie
            vc.golfer = self.golfer
        }
    }
    
    @objc func seeAllLoops() {
        performSegue(withIdentifier: "allloopssegue", sender: self)
    }

    
    func authHeaders() -> HTTPHeaders {
        let token = KeychainWrapper.standard.string(forKey: "token")
        let headers : HTTPHeaders = [
            "Authorization":"Bearer \(token!)",
            "Accept": "application/json"
        ]
        
        return headers
    }
    
    
    @objc func cancelLoop() {
        let CANCEL_URL = "http://0.0.0.0:8000/api/v1/loops/\(loop.id)/cancel"
        let headers = authHeaders()
        
        Alamofire.request(CANCEL_URL, method: .post, headers: headers).validate(statusCode: 200...299).response { (response) in
            print(response.data)
        }
    }
    
    @objc func acceptLoop() {
        let ACCEPT_URL = "http://0.0.0.0:8000/api/v1/loops/\(loop.id)/accept"
        let headers = authHeaders()
        print("You clicked me!")
        
        Alamofire.request(ACCEPT_URL, method: .post, headers: headers).validate(statusCode: 200...299).response { (response) in
            print(response.data)
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
    
    

}
