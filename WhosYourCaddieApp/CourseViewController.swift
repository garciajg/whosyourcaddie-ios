//
//  CourseViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 7/24/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class CourseViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    var loop = Loop()
    var course = Course()
    var golfer = Golfer()
    
    let COURSE_URL = "http://0.0.0.0:8000/api/v1/courses"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTableViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable as UISearchResultsUpdating
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        
        locationSearchTable.handleMapSearchDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.5, 0.5)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
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
        let placemark = selectedPin
        let courseName = placemark?.name as! String
        let city = placemark?.locality as! String
        let state = placemark?.administrativeArea as! String
        
        let message = "Are you sure you want to play \(courseName) in \(city), \(state)"
        self.showSelectedCourseAlert(title: courseName, message: message)

    }
    
    func showSelectedCourseAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "Confirm", style: .default) { (action) in
            let placemark = self.selectedPin
            if let dict = placemark?.addressDictionary as? NSDictionary {
                let id = dict.hashValue
                print("id: \(id)")
                print("\(dict)")
            }
            let lat = placemark?.coordinate.latitude as! Double
            let lon = placemark?.coordinate.longitude as! Double
            let name = placemark?.name
            
            self.saveCourse(latitude: lat, longitude: lon, courseName: name!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(acceptAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
     
    */
    
    func saveCourse(latitude:Double, longitude:Double, courseName:String) {
        let headers = authHeaders()
        
        let parameters = [
            "course_name": courseName,
            "latitude": latitude,
            "longitude": longitude
            ] as [String : Any]
        print(parameters)
        
        Alamofire.request(COURSE_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200...299).responseData { (courseData) in
            switch courseData.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                let crs = Course()
                crs.latitude = json["latitude"].float!
                crs.longitude = json["longitude"].float!
                crs.name = json["course_name"].string!
                crs.id = json["id"].int!
                self.loop.course = crs
                self.performSegue(withIdentifier: "createloopsegue", sender: self)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createloopsegue" {
            let vc = segue.destination as! CreateLoopViewController
            vc.loop = self.loop
            vc.golfer = self.golfer
            print("CourseVC GolferID: \(self.golfer.golferID)")
        }
    }

}

extension CourseViewController : HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        //cache the pin
        selectedPin = placemark
        //remove existing pin
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city), \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
    }
    
    
}
