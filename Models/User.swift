//
//  User.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 7/23/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit

class User {
    
    var id : Int = 0
    var firstName : String = ""
    var lastName : String = ""
    var email : String = ""
    var state : String = ""
    var address : String = ""
    var city : String = ""
    var phoneNumber : String = ""
    var zipcode : String = ""
    var dateOfBirth : String = ""
    var userType : String = ""
    var loops : [Loop] = []
    var reviews : [Review] = []

}

class Caddie: User {
    
    var user = User()

    var rating : Double = 0.0
    var greenSkills : Double = 0.0
    
}

class Golfer:User {
    
}
