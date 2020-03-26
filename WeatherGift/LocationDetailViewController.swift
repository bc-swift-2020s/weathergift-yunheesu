//
//  LocationDetailViewController.swift
//  WeatherGift
//
//  Created by Heesu Yun on 3/22/20.
//  Copyright © 2020 Heesu Yun. All rights reserved.
//

import UIKit

private let dateFormatter: DateFormatter = {
    print("📆 I JUST CREATED A DATE FORMATTER")
    let dateFormatter = DateFormatter ()
    dateFormatter.dateFormat = "EEEE, MMM, d, h:mm:aaa"
    return dateFormatter
    
}() // () <- this executes closure

class LocationDetailViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var locationIndex = 0 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUserInterface()
    }
    
    
    func updateUserInterface () {
        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController //finding rootViewController for 1st window that gives pageViewController
        let weatherLocation = pageViewController.weatherLocations[locationIndex]
        let weatherDetail = WeatherDetail(name: weatherLocation.name, latitude: weatherLocation.latitude, longitude: weatherLocation.longitude)
        
        pageControl.numberOfPages = pageViewController.weatherLocations.count
        pageControl.currentPage = locationIndex
        
        weatherDetail.getData {
            DispatchQueue.main.async {
                dateFormatter.timeZone = TimeZone(identifier: weatherDetail.timezone)
                let usableDate = Date(timeIntervalSince1970: weatherDetail.currentTime)
                self.dateLabel.text = dateFormatter.string(from: usableDate) //assigning dates to each timezone (시차)
                self.placeLabel.text = weatherDetail.name
                self.temperatureLabel.text = "\(weatherDetail.temperature)°" // string으로 바꾸는법
                self.summaryLabel.text = weatherDetail.summary
                self.imageView.image = UIImage(named: weatherDetail.dailyIcon) // adding images to weather
            }
        } 
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! LocationListViewController
        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
        destination.weatherLocations = pageViewController.weatherLocations
    }
    
    @IBAction func unwindFromLocationListViewController(segue: UIStoryboardSegue){
        let source = segue.source as! LocationListViewController
        locationIndex = source.selectedLocationIndex
        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
        pageViewController.weatherLocations = source.weatherLocations
        pageViewController.setViewControllers([pageViewController.createLocationDetailViewController(forPage: locationIndex)], direction: .forward, animated: false, completion: nil)
    }
    @IBAction func pageControlTapped(_ sender: UIPageControl) { // to move side to side by clicking the dots below
        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
        
        var direction: UIPageViewController.NavigationDirection = .forward
        if sender.currentPage < locationIndex {//locationIndex = index of page we are looking / current page is where we are heading
            direction = .reverse
            
            pageViewController.setViewControllers([pageViewController.createLocationDetailViewController(forPage: sender.currentPage)], direction: direction, animated: true, completion: nil)
        }
        
    }
}
