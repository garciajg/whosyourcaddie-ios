//
//  MatchingCollectionViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 9/11/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MatchingCollectionViewController: UICollectionViewController {
    
    var questionsArray : [MatchingQuestion] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    func questionArray() {
        let opts = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P"]
        questionsArray.append(MatchingQuestion(text: "A piece of sod or turf cut loose by a player's club after making a stroke",
                                               options: opts,
                                               correctA: "D"))
        questionsArray.append(MatchingQuestion(text: "A warning shouted to let a person know that a ball in flight may hit him/her or come very close",
                                               options: opts,
                                               correctA: "I"))
        questionsArray.append(MatchingQuestion(text: "A shot, hit by a right-handed player, which curves slightly right",
                                               options: opts,
                                               correctA: "H"))
        questionsArray.append(MatchingQuestion(text: "The amount of strokes taken with handicap included",
                                               options: opts,
                                               correctA: "L"))
        questionsArray.append(MatchingQuestion(text: "A score one stroke under par for the hole",
                                               options: opts,
                                               correctA: "A"))
        questionsArray.append(MatchingQuestion(text: "Path in which the ball is intended to travel over the putting green to the hole. Do not step on this while on the green",
                                               options: opts,
                                               correctA: "O"))
        questionsArray.append(MatchingQuestion(text: "The amount of strokes taken without handicap",
                                               options: opts,
                                               correctA: "K"))
        questionsArray.append(MatchingQuestion(text: "Ground on which play is prohibited, usually outside the golf course's property. It is usually marked with white stakes or boundary fences",
                                               options: opts,
                                               correctA: "M"))
        questionsArray.append(MatchingQuestion(text: "A shot, hit by a right-handed player, which curves slightly left",
                                               options: opts,
                                               correctA: "F"))
        questionsArray.append(MatchingQuestion(text: "The closely mowed collar around the putting green",
                                               options: opts,
                                               correctA: "J"))
        questionsArray.append(MatchingQuestion(text: "A score one stroke over par for the hole",
                                               options: opts,
                                               correctA: "B"))
        questionsArray.append(MatchingQuestion(text: "A score two strokes under par for the hole",
                                               options: opts,
                                               correctA: "G"))
        questionsArray.append(MatchingQuestion(text: "A hole which goes right or left and does not follow a staight line from the tee",
                                               options: opts,
                                               correctA: "E"))
        questionsArray.append(MatchingQuestion(text: "The standard score for the hole, usually based on its length",
                                               options: opts,
                                               correctA: "P"))
        questionsArray.append(MatchingQuestion(text: "A ball played for the orignal ball which may be lost outside if a water hazard or may be out of bounds",
                                               options: opts,
                                               correctA: "N"))
        questionsArray.append(MatchingQuestion(text: "A depression where the turf or soil has been removed and replaced with sand. It is a hazard. Often improperly called a \"sand trap\"",
                                               options: opts,
                                               correctA: "C"))
        
    }

}
