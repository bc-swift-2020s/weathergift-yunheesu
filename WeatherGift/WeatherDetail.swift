//
//  WeatherDetail.swift
//  WeatherGift
//
//  Created by Heesu Yun on 3/23/20.
//  Copyright © 2020 Heesu Yun. All rights reserved.
//

import Foundation

class WeatherDetail: WeatherLocation { //subclass
    
    struct Result: Codable {
        var timezone: String
        var currently: Currently
        var daily: Daily
        
    }
    struct Currently: Codable {
        var temperature: Double
    }
    struct Daily: Codable {
        var summary: String
        var icon: String
    }
    
    var timezone = ""
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
                let result = try JSONDecoder().decode(Result.self, from: data!)
//                print("😎 \(result)")
//                print("The timezone for \(self.name) is : \(result.timezone)")
                self.timezone = result.timezone
                self.temperature = Int(result.currently.temperature.rounded()) // declating tempt as Int
                self.summary = result.daily.summary
                self.dailyIcon = result.daily.icon
            }catch{
                print("😡 JSON ERROR: \(error.localizedDescription)")
            }
            completed()
        }
        task.resume()
    }
    
}
