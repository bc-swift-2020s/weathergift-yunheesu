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

private let hourlyFormatter: DateFormatter = {
    print("⏰⏰ I JUST CREATED An HOURLY FORMATTER in WeatherDetail.swift")
    let dateFormatter = DateFormatter ()
    dateFormatter.dateFormat = "ha" // ha: hour + am or pm
    return dateFormatter //or hourlyFormatter
    
}()

struct DailyWeather: Codable { // getting weather for each day for 7 days!
    var dailyIcon: String
    var dailyWeekday: String
    var dailySummary: String
    var dailyHigh: Int
    var dailyLow: Int
}
struct HourlyWeather: Codable {
    var hour: String
    var hourlyIcon: String
    var hourlyTemperature: Int
    var hourlyPrecipProbability: Int
    
}

class WeatherDetail: WeatherLocation { //subclass
    
    private struct Response: Codable { // private --> only available in this  file // Codable - to get anything from json data
        var timezone: String
        var currently: Currently
        var daily: Daily
        var hourly: Hourly
        
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
    private struct Hourly: Codable {
        var data: [HourlyData]
    }
    
    private struct HourlyData: Codable {
        var icon: String
        var time: TimeInterval
        var temperature: Double
        var precipProbability: Double
    }
    
    var timezone = ""
        var currentTime = 0.0
    var temperature = 0 // declaring as Int not Double
    var summary = ""
    var dailyIcon = "" // adding images to weather
    var dailyWeatherData: [DailyWeather] = [] // starts with an empty array and holds data for tableView
    var hourlyWeatherData: [HourlyWeather] = []
    
    
    

        
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
                    let dailyWeather = DailyWeather(dailyIcon: dailyIcon, dailyWeekday: dailyWeekDay, dailySummary: dailySummary, dailyHigh: dailyHigh, dailyLow: dailyLow)
                    self.dailyWeatherData.append(dailyWeather)
                }
                let lastHour = min(24, response.hourly.data.count)
                for index in 0..<lastHour {
                    let hourlyDate = Date(timeIntervalSince1970: response.hourly.data[index].time)
                    hourlyFormatter.timeZone = TimeZone(identifier: response.timezone)
                    let hour = hourlyFormatter.string(from: hourlyDate)
                    let hourlyIcon = response.hourly.data[index].icon
                    let precipProbability = Int((response.hourly.data[index].precipProbability*100).rounded()) // changing Double to Int, and changing to 100 with rounded value
                    let temperature = Int(response.hourly.data[index].temperature.rounded())
                    let hourlyWeather = HourlyWeather(hour: hour, hourlyIcon: hourlyIcon, hourlyTemperature: temperature, hourlyPrecipProbability: precipProbability)
                    self.hourlyWeatherData.append(hourlyWeather) // append to HourlyWeather data

                }
            }catch{
                print("😡 JSON ERROR: \(error.localizedDescription)")
            }
            completed()
        }
        task.resume()
    }
    
}
