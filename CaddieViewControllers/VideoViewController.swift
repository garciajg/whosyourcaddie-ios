//
//  VideoViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 9/14/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {

    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var videoTwoButton: UIButton!
    @IBOutlet weak var videoThreeButton: UIButton!
    
    var user = User()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(user.userType)
        // Do any additional setup after loading the view.
        videoButton.layer.cornerRadius = videoButton.frame.size.height / 2
        videoTwoButton.layer.cornerRadius = videoTwoButton.frame.size.height / 2
        videoThreeButton.layer.cornerRadius = videoThreeButton.frame.size.height / 2
        videoButton.clipsToBounds = true
        videoTwoButton.clipsToBounds = true
        videoThreeButton.clipsToBounds = true
        
        let doneButton = UIBarButtonItem(title: "Done",
                                         style: .plain,
                                         target: self,
                                         action: #selector(startQuestions))
        
        self.navigationItem.rightBarButtonItem = doneButton

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressVideoButton(_ sender: Any) {
        let youtubeId = "IvoMyGyg4PI"
        openYoutubeVideo(withYoutubeId: youtubeId)
    }

    
    @IBAction func didPressVideoTwoButton(_ sender: Any) {
        let youtubeId = "PyMIS930Rtk"
        openYoutubeVideo(withYoutubeId: youtubeId)
    }
    
    
    @IBAction func didPressVideoThreeButton(_ sender: Any) {
        let youtubeId = "fZbr_ShGw8g"
        openYoutubeVideo(withYoutubeId: youtubeId)
    }
    
    func openYoutubeVideo(withYoutubeId youtubeId:String) {
        var youtubeUrl = URL(string:"youtube://\(youtubeId)")!
        if UIApplication.shared.canOpenURL(youtubeUrl){
            UIApplication.shared.open(youtubeUrl, options:[:], completionHandler:nil)
        } else{
            youtubeUrl = URL(string:"https://www.youtube.com/watch?v=\(youtubeId)")!
            UIApplication.shared.open(youtubeUrl, options:[:], completionHandler:nil)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let vc = segue.destination as! QuestionCollectionViewController
        vc.user = self.user
    }
    
    @objc func startQuestions() {
        self.performSegue(withIdentifier: "questionsegue", sender: self)
    }

}
