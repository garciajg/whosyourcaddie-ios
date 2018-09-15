//
//  HoleQuestionsCollectionViewCell.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 9/11/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit

class HoleQuestionsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var questionTextLabel: UILabel!
    
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var userInput: UITextField!
    
    func setUp(question:MatchingQuestion) {
        switch question.userAnswer {
        case question.userAnswer:
            userInput.text = question.userAnswer
            
        default:
            userInput.text = ""
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userInput.text = userInput.text
    }
}
