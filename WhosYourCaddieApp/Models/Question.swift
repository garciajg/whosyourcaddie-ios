//
//  File.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 8/23/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import Foundation

class Question {
    
    let questionText : String
    let ansOptions : [String]
    let correctAnswer : [String]
    var userAnswers : [String] = []
    var score : Float = 0.0
    
    init(text : String, options: [String], correctAns: [String]) {
        questionText = text
        ansOptions = options
        correctAnswer = correctAns
    }
}

class MatchingQuestion {
    
    let questionText : String
    let ansOptions : [String]
    let correctAns : String
    var userAnswer : String = ""
    var score : Float = 0.0
    
    //    var questionsArray : [MatchingQuestion] = []
    
    init(text: String, options:[String], correctA:String) {
        questionText = text
        ansOptions = options
        correctAns = correctA
    }
}
