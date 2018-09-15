//
//  LoopDetailViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 9/6/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit
import MapKit

class LoopDetailViewController: UIViewController, MKMapViewDelegate {
    
    var loop = Loop()
    var caddie = Caddie()

    @IBOutlet weak var loopDetailLabel: UILabel!
    @IBOutlet weak var loopCourseMapView: MKMapView!
    @IBOutlet weak var cancelLoopButton: UIButton!
    @IBOutlet weak var courseMapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let message = """
        Your loop is at \(loop.startTime) on \(loop.loopDate) with \(loop.golfer?.firstName) \(loop.golfer?.lastName). \n
        It will be at \(loop.course?.name). Make sure you arrive at least 15 minutes early for warm up. Have fun!
        """
        loopDetailLabel.text = message
        courseMapView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        <#code#>
    }
    
    @IBAction func didPressCancelLoop(_ sender: Any) {
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
