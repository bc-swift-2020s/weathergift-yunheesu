//
//  WeatherDetail.swift
//  WeatherGift
//
//  Created by Heesu Yun on 3/23/20.
//  Copyright © 2020 Heesu Yun. All rights reserved.
//

import Foundation

class WeatherDetail: WeatherLocation { //subclass
    
    struct Response: Codable {
        var timezone: String
        var currently: Currently
        var daily: Daily
        
    }
    struct Currently: Codable {
        var temperature: Double
        var time: TimeInterval
    }
    struct Daily: Codable {
        var summary: String
        var icon: String
    }
    
    var timezone = ""
        var currentTime = 0.0
    var temperature = 0 // declaring as Int not Double
    var summary = ""
    var dailyIcon = "" // adding images to weather

        
    func getData(completed: @escaping () -> ()) { //escaping closure to get data until you've gotten the data
        let coordinates = "\(latitude),\(longitude)"
        let urlString = "\(APIurls.darkSkyURL)\(APIkeys.darkSkyKey)/\(coordinates)"
        
        print("🕸 We are accessing the url \(urlString)")
        //Create a URL
        guard let url = URL(string: urlString) else{
            print("😡 ERROR: could not create URL from \(urlString)")
            completed()
            return
        }
        //Create Session
        let session = URLSession.shared
        
        //Get data with .dataTask method
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("😡 ERROR: \(error.localizedDescription)")
            }
            
            //note: there are some additional things that could go wrong when using URL session, but we shouldn't experience them, so we'll ignore testing for these for now
            
            //deal with data
            do {
                let response = try JSONDecoder().decode(Response.self, from: data!)
                self.timezone = response.timezone
                self.currentTime = response.currently.time
                self.temperature = Int(response.currently.temperature.rounded()) // declating tempt as Int
                self.summary = response.daily.summary
                self.dailyIcon = response.daily.icon
            }catch{
                print("😡 JSON ERROR: \(error.localizedDescription)")
            }
            completed()
        }
        task.resume()
    }
    
}
