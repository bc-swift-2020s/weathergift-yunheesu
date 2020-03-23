//
//  WeatherLocation.swift
//  WeatherGift
//
//  Created by Heesu Yun on 3/8/20.
//  Copyright © 2020 Heesu Yun. All rights reserved.
//

import Foundation

class WeatherLocation: Codable { // using class instead of struct
    var name: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, latitude: Double, longitude: Double){
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
  
}
