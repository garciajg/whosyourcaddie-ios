//
//  CreateLoopViewController.swift
//  
//
//  Created by Jose Garcia on 8/29/18.
//

import UIKit
import Segmentio
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper
import SkeletonView

class CreateLoopViewController: UIViewController {

    @IBOutlet weak var segmentioView: Segmentio!
    
    @IBOutlet weak var nineHoleButton: UIButton!
    @IBOutlet weak var eighteenHoleButton: UIButton!
    @IBOutlet weak var walkingButton: UIButton!
    @IBOutlet weak var ridingButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    var numberOfHoles: String = "EITN"
    var isWalking: Bool  = true
    
    var loop = Loop()
    var golfer = Golfer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loop.isWalking = isWalking
        loop.numberOfHoles = numberOfHoles
//        setUpSegmentio()
        print(loop.course?.name ?? "No course Selected")
        let rightButton = UIBarButtonItem(title: "Caddies",
                                          style: .plain,
                                          target: self,
                                          action: #selector(viewCaddies))
        
        self.navigationItem.rightBarButtonItem = rightButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        datePicker.minimumDate = Date()
    }
    
    @IBAction func didDatePickerChange(_ sender: Any) {
        loop.loopDate = formattedDate()
    }
    
    
    @IBAction func didTimePickerChange(_ sender: Any) {
        loop.startTime = formattedTime()
    }
    
    @objc func viewCaddies() {
        performSegue(withIdentifier: "availablecaddiessegue", sender: self)
    }
    
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "availablecaddiessegue" {
            let vc = segue.destination as! AvailableCaddiesTableViewController
            vc.golfer = self.golfer
            vc.loop = self.loop
        }
    }

    
    //MARK: - Buttons Pressed
    
    @IBAction func didPressNineButton(_ sender: Any) {
        numberOfHoles = "NINE"
        eighteenHoleButton.setTitleColor(blueButtonColor(), for: .normal)
        eighteenHoleButton.backgroundColor = greenButtonColor()
        nineHoleButton.setTitleColor(greenButtonColor(), for: .normal)
        nineHoleButton.backgroundColor = blueButtonColor()
        loop.numberOfHoles = numberOfHoles
    }
    
    @IBAction func didPressEighteenButton(_ sender: Any) {
        numberOfHoles = "EITN"
        nineHoleButton.setTitleColor(blueButtonColor(), for: .normal)
        nineHoleButton.backgroundColor = greenButtonColor()
        eighteenHoleButton.setTitleColor(greenButtonColor(), for: .normal)
        eighteenHoleButton.backgroundColor = blueButtonColor()
        loop.numberOfHoles = numberOfHoles

    }
    
    @IBAction func didPressWalkingButton(_ sender: Any) {
        isWalking = true
        ridingButton.setTitleColor(blueButtonColor(), for: .normal)
        ridingButton.backgroundColor = greenButtonColor()
        walkingButton.setTitleColor(greenButtonColor(), for: .normal)
        walkingButton.backgroundColor = blueButtonColor()
        loop.isWalking = isWalking
    }
    
    @IBAction func didPressRidingButton(_ sender: Any) {
        isWalking = false
        walkingButton.setTitleColor(blueButtonColor(), for: .normal)
        walkingButton.backgroundColor = greenButtonColor()
        ridingButton.setTitleColor(greenButtonColor(), for: .normal)
        ridingButton.backgroundColor = blueButtonColor()
        loop.isWalking = isWalking

    }
    
    //MARK: - Setup Segmented Controller
    func setUpSegmentio() {
        
        
        var content = [SegmentioItem]()
        let nine = SegmentioItem(title: "Nine Holes",
                                 image: UIImage(named: "golfapp"))
        content.append(nine)
        let eighteen = SegmentioItem(title: "Eighteen Holes",
                                     image: UIImage(named: "golfapp"))
        content.append(eighteen)
        
        segmentioView.setup(content: content,
                            style: SegmentioStyle.imageOverLabel,
                            options: nil)
    }
    
    func blueButtonColor() -> UIColor {
        return UIColor(red: 81.0/255.0, green: 106.0/255.0, blue: 250.0/255.0, alpha: 1)
    }
    
    func greenButtonColor() -> UIColor {
        return UIColor(red: 136.0/255.0, green: 1.0, blue: 226.0/255.0, alpha: 1)
    }
    
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: datePicker.date)
        
        return formattedDate
    }
    
    func formattedTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let formattedTime = dateFormatter.string(from: timePicker.date)
        
        return formattedTime
    }
    
    func postLoopInfo(loop:Loop) {
        let headers = authHeaders()
        let parameters = [
            "loop_date":loop.loopDate,
            "start_time":loop.startTime,
            "course":loop.course,
            "golfer": golfer
        ] as [String:Any]
    }
    
    func authHeaders() -> HTTPHeaders {
        let token = KeychainWrapper.standard.string(forKey: "token") as! String
        let headers : HTTPHeaders = [
            "Authorization":"Bearer \(token)",
            "Accept": "application/json"
        ]
        
        return headers
    }

}
