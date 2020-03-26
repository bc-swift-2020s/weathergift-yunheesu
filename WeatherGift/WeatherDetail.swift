//
//  WeatherDetail.swift
//  WeatherGift
//
//  Created by Heesu Yun on 3/23/20.
//  Copyright © 2020 Heesu Yun. All rights reserved.
//

import Foundation

private let dateFormatter: DateFormatter = {
    print("📆📆📆 I JUST CREATED A DATE FORMATTER in WeatherDetail.swift")
    let dateFormatter = DateFormatter ()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter
    
}()

struct DailyWeatherData: Codable { // getting weather for each day for 7 days!
    var dailyIcon: String
    var dailyWeekday: String
    var dailySummary: String
    var dailyHigh: Int
    var dailyLow: Int
}

class WeatherDetail: WeatherLocation { //subclass
    
    private struct Response: Codable { // private --> only available in this  file // Codable - to get anything from json data
        var timezone: String
        var currently: Currently
        var daily: Daily
        
    }
    private struct Currently: Codable {
        var temperature: Double
        var time: TimeInterval
    }
    private struct Daily: Codable {
        var summary: String
        var icon: String
        var data: [DailyData] // data same as name in json
    }
    
    private struct DailyData: Codable {
        var icon: String
        var time: TimeInterval
        var summary: String
        var temperatureHigh: Double
        var temperatureLow: Double
        
    }
    var timezone = ""
        var currentTime = 0.0
    var temperature = 0 // declaring as Int not Double
    var summary = ""
    var dailyIcon = "" // adding images to weather
    var dailyWeatherData: [DailyWeatherData] = [] // starts with an empty array
    
    

        
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
                for index in 0..<response.daily.data.count {
                    let weekdayDate = Date(timeIntervalSince1970: response.daily.data[index].time) // get unixData to iOS swift date
                    dateFormatter.timeZone = TimeZone(identifier: response.timezone)
                    let dailyWeekDay = dateFormatter.string(from: weekdayDate)
                    let dailyIcon = response.daily.data[index].icon
                    let dailySummary = response.daily.data[index].summary
                    let dailyHigh = Int(response.daily.data[index].temperatureHigh.rounded())
                    let dailyLow = Int(response.daily.data[index].temperatureLow.rounded())
                    let dailyWeather = DailyWeatherData(dailyIcon: dailyIcon, dailyWeekday: dailyWeekDay, dailySummary: dailySummary, dailyHigh: dailyHigh, dailyLow: dailyLow)
                    self.dailyWeatherData.append(dailyWeather)
                    print("Day: \(dailyWeather.dailyWeekday) High: \(dailyWeather.dailyHigh) Low: \(dailyWeather.dailyLow)")
                }
            }catch{
                print("😡 JSON ERROR: \(error.localizedDescription)")
            }
            completed()
        }
        task.resume()
    }
    
}
