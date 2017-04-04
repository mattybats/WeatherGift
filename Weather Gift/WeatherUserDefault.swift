//
//  WeatherUserDefault.swift
//  Weather Gift
//
//  Created by John Gallaugher on 3/25/17.
//  Copyright © 2017 Gallaugher. All rights reserved.
//

import Foundation

class WeatherUserDefault: NSObject, NSCoding {
    
    var name = ""
    var coordinates = ""
    
    override init() {
        super.init()
    }
    
    // Again, this says when we read raw data and we need to decode.  We look for the
    // "name" that's a string, and we look for a "coordinates" which is also a String.
    // a coder will grab row stuff from disk and we'll tell it how to format this data.
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
        coordinates = aDecoder.decodeObject(forKey: "coordinates") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        // Hunt for the name variable in our class and put a key in front of it so that we can recognize the name when we decode it.
        aCoder.encode(name, forKey: "name")
        aCoder.encode(coordinates, forKey: "coordinates")
    }
}
