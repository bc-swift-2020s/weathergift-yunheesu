//
//  LocationDetailViewController.swift
//  WeatherGift
//
//  Created by Heesu Yun on 3/22/20.
//  Copyright © 2020 Heesu Yun. All rights reserved.
//

import UIKit
import CoreLocation

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter ()
    dateFormatter.dateFormat = "EEEE, MMM, d"
    return dateFormatter
    
}() // () <- this executes closure

class LocationDetailViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var locationIndex = 0
    var weatherDetail: WeatherDetail! // changing weatherDetail to class-wide property
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) { //main view is about to appear
        super.viewWillAppear(animated)
        
        clearUserInterface()
        
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if locationIndex == 0 {
            getLocation()
        }
        updateUserInterface()
    }
    
    func clearUserInterface() {
        dateLabel.text = ""
        placeLabel.text = ""
        temperatureLabel.text = ""
        summaryLabel.text = ""
        imageView.image = UIImage()
    }
    
    func updateUserInterface () {
        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController //finding rootViewController for 1st window that gives pageViewController
        let weatherLocation = pageViewController.weatherLocations[locationIndex]
        weatherDetail = WeatherDetail(name: weatherLocation.name, latitude: weatherLocation.latitude, longitude: weatherLocation.longitude)
        
        pageControl.numberOfPages = pageViewController.weatherLocations.count
        pageControl.currentPage = locationIndex
        
        weatherDetail.getData {
            DispatchQueue.main.async {
                dateFormatter.timeZone = TimeZone(identifier: self.weatherDetail.timezone)
                let usableDate = Date(timeIntervalSince1970: self.weatherDetail.currentTime) // changing unixdata to ios data
                self.dateLabel.text = dateFormatter.string(from: usableDate) //assigning dates to each timezone (시차)
                self.placeLabel.text = self.weatherDetail.name
                self.temperatureLabel.text = "\(self.weatherDetail.temperature)°" // string으로 바꾸는법
                self.summaryLabel.text = self.weatherDetail.summary
                self.imageView.image = UIImage(named: self.weatherDetail.dailyIcon) // adding images to weather
                self.tableView.reloadData()
                self.collectionView.reloadData()
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
extension LocationDetailViewController: UITableViewDelegate, UITableViewDataSource { // including a tableviewCell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDetail.dailyWeatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DailyTableViewCell // new custom TableViewCell for sepcific properties for new tableViewCell
        cell.dailyWeather = weatherDetail.dailyWeatherData[indexPath.row] //kick of property observer, associate w/ dailyweather in dailytable view cell that will updatte IBoutlet
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // keep height constant
    }
}
extension LocationDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherDetail.hourlyWeatherData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let hourlyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! HourlyCollectionViewCell
        hourlyCell.hourlyWeather = weatherDetail.hourlyWeatherData[indexPath.row]
        return hourlyCell
    }
    
    
}

extension LocationDetailViewController: CLLocationManagerDelegate { // to get currentLocation
    
    func getLocation() {
        //Creating a CLLocationManager will automatically check authorization
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {//for authentication status
        print("Checking authentication status.")
        handleAuthenticalStatus(status: status)
        
        
    }
    func handleAuthenticalStatus(status: CLAuthorizationStatus) { //function made by me
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization() // requesting user permission
        case .restricted:
            self.oneButtonAlert(title: "Location services denied", message: "It may be that parental controls are restricting location use in this app.")
        case .denied:
            //TODO: handle alert w/ ability to change
        break //access executable statement that does nothing but silence the error
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            print("DEVELOPER alert: unknown case of status in handleAuthenticalStatus \(status)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //TODO: Deal with change in location
        print("updating location") // when permission to use location is given
        let currentLocation = locations.last ?? CLLocation()
        print("Current location is \(currentLocation.coordinate.latitude) \(currentLocation.coordinate.longitude)")
        let geocoder = CLGeocoder() // getting the name of the current location!
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            var locationName = ""
            if placemarks != nil {
                //get the first placemakr
                let placemark = placemarks?.last
                //assign placemark to locationName
                locationName = placemark?.name ?? "Parts unknown"
            }else{
                print("ERROR: retrieving place. Error code \(error!.localizedDescription)")
                locationName = "Could not find location"
            }
            print("locationName = \(locationName)")
            
            //update weatherLocations[0] with the current location so it can be used in updateUserInterface. getLocation only when locationIndex == 0
            let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController //finding rootViewController for 1st window that gives pageViewController
            pageViewController.weatherLocations[self.locationIndex].latitude = currentLocation.coordinate.latitude
            pageViewController.weatherLocations[self.locationIndex].longitude =
                currentLocation.coordinate.longitude
            pageViewController.weatherLocations[self.locationIndex].name = locationName
            
            self.updateUserInterface()
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //TODO: Deal with error
        print("ERROR: \(error.localizedDescription). Failed to get device location.")
    }
}
