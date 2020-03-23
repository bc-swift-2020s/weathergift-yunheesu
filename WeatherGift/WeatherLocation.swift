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
    
    func getData() {
        let coordinates = "\(latitude),\(longitude)"
        let urlString = "\(APIurls.darkSkyURL)\(APIkeys.darkSkyKey)/\(coordinates)"
        
        print("🕸 We are accessing the url \(urlString)")
        //Create a URL
        guard let url = URL(string: urlString) else{
            print("😡 ERROR: could not create URL from \(urlString)")
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
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                print("😎 \(json)")
            }catch{
                print("😡 JSON ERROR: \(error.localizedDescription)")
        }
    }
        task.resume()
}
}
