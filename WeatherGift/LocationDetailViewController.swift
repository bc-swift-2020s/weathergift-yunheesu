//
//  LocationDetailViewController.swift
//  WeatherGift
//
//  Created by Heesu Yun on 3/22/20.
//  Copyright © 2020 Heesu Yun. All rights reserved.
//

import UIKit

class LocationDetailViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var weatherLocation: WeatherLocation!
    var locationIndex = 0 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUserInterface()
    }
    
    
    func updateUserInterface () {
        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController //finding rootViewController for 1st window that gives pageViewController
        weatherLocation = pageViewController.weatherLocations[locationIndex]
        
        dateLabel.text = ""
        placeLabel.text = weatherLocation.name
        temperatureLabel.text = "--°"
        summaryLabel.text = ""
        
        pageControl.numberOfPages = pageViewController.weatherLocations.count
        pageControl.currentPage = locationIndex
        weatherLocation.getData()
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
