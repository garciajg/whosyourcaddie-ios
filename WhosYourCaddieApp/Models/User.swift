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
    var age : Int = 0
    var profilePicture : URL = URL(string: "https://vokal-io.s3.amazonaws.com/da837327b8937691012a89e212e580bc.jpg")!
}

class Caddie: User {
    
    var user = User()
    var caddieID : Int = 0
    var rating : Double = 0.0
    var greenSkills : Double = 0.0
    var ranking : String = ""
    
}

class Golfer:User {
    var user = User()
    var golferID : Int = 0
    
    
}
