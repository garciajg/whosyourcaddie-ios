//
//  QuestionCollectionViewCell.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 8/30/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit

class QuestionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nextQButton: UIButton!
    
    @IBOutlet weak var answerOneLabel: UILabel!
    @IBOutlet weak var answerTwoLabel: UILabel!
    @IBOutlet weak var answerThreeLabel: UILabel!
    @IBOutlet weak var answerFourLabel: UILabel!
    @IBOutlet weak var questionTextLabel: UILabel!
    
    
    func setUp(question: Question) {
        let redColor = UIColor.alizarin
        let initialColor = UIColor(red: 186/255, green: 237/255, blue: 1, alpha: 1)
        
        
        for a in question.userAnswers {
            switch a {
            case "t":
                answerOneLabel.backgroundColor = redColor
                
            case "f":
                answerTwoLabel.backgroundColor = redColor
                
            case "a":
                answerOneLabel.backgroundColor = redColor
                
            case "b":
                answerTwoLabel.backgroundColor = redColor
                
            case "c":
                answerThreeLabel.backgroundColor = redColor
                
            case "d":
                answerFourLabel.backgroundColor = redColor
                
            default:
                answerOneLabel.backgroundColor = initialColor
                answerTwoLabel.backgroundColor = initialColor
                answerThreeLabel.backgroundColor = initialColor
                answerFourLabel.backgroundColor = initialColor
            }
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        answerOneLabel.backgroundColor = UIColor(red: 186/255, green: 237/255, blue: 1, alpha: 1)
        answerTwoLabel.backgroundColor = UIColor(red: 186/255, green: 237/255, blue: 1, alpha: 1)
        answerThreeLabel.backgroundColor = UIColor(red: 186/255, green: 237/255, blue: 1, alpha: 1)
        answerFourLabel.backgroundColor = UIColor(red: 186/255, green: 237/255, blue: 1, alpha: 1)
    }
    
}

