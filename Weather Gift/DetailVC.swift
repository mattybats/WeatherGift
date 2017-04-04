//
//  DetailVC.swift
//  Weather Gift
//
//  Created by John Gallaugher on 2/11/17.
//  Copyright © 2017 Gallaugher. All rights reserved.
//

import UIKit
import CoreLocation

class DetailVC: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var currentImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!

    var currentPage = 0
    var locationsArray = [WeatherLocation]()
    var locationManager = CLLocationManager()
    var currentLocation : CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        locationsArray[currentPage].getWeather {
            self.updateUserInterface()
            print("**** locationsArray[self.currentPage].currentTemp = \(self.locationsArray[self.currentPage].currentTemp))")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentPage == 0 {
            getLocation()
        }
    }
    
    func updateUserInterface() {
        let isHidden = (locationsArray[currentPage].currentTemp == -999.9)
        temperatureLabel.isHidden = isHidden
        locationLabel.isHidden = isHidden

        locationLabel.text = locationsArray[currentPage].name
        
        if locationsArray[currentPage].currentTime == 0.0 {
            dateLabel.text = ""
        } else {
            dateLabel.text = formatTimeForTimeZone(unixDateToFormat: locationsArray[currentPage].currentTime, timeZoneString: locationsArray[currentPage].timeZone)
        }
        
        let curTemperature = String(format: "%3.f", locationsArray[currentPage].currentTemp) + "°"
        temperatureLabel.text = curTemperature
        summaryLabel.text = locationsArray[currentPage].dailySummary
        currentImage.image = UIImage(named: locationsArray[currentPage].currentIcon)
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func formatTimeForTimeZone(unixDateToFormat: TimeInterval, timeZoneString: String) -> String {
        // Convert the Unix date to a usable iOS Date type
        let usableDate = Date(timeIntervalSince1970: unixDateToFormat)
        
        // Create a DateFormatter object called dateFormatter
        let dateFormatter = DateFormatter()
        
        // Set the .dateFormat property of the DateFormatter object
        // to convert Weekday (EEEE), Month abbreviation (MMM) day (dd), year (y)
        dateFormatter.dateFormat = "EEEE, MMM dd, y"
        
        // Set the .timeZone property of hte DateFormatter object
        dateFormatter.timeZone = TimeZone(identifier: timeZoneString)
        
        // Convert the iOS Date, usableDate, to a .dateFormatted string in .timeZone.
        let dateString = dateFormatter.string(from: usableDate)
        
        // Return the formatted String
        return dateString
    }
}

extension DetailVC: CLLocationManagerDelegate {
    
    // Called from viewDidLoad() to get location when this scene loads
    func getLocation() {
        let status = CLLocationManager.authorizationStatus()
        handleLocationAuthorizationStatus(status: status)
    }
    
    // Respond to the result of the location manager authorization status
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied:
            if currentPage == 0 && self.view.window != nil {
                showAlert(title: "User has not authorized location services", message: "Open the Settings app > Privacy > Location Services > WeatherGift to enable location services in this app.")
            }
        case .restricted:
            showAlert(title: "Location Services Denied", message: "It may be that parental controls are restricting location use in this app.")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // This function is called if status is changed. If so, handle the
    //  status change
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if currentPage == 0 && self.view.window != nil {
            let geoCoder = CLGeocoder()
            
            currentLocation = locations.last
            
            let currentLat = "\(currentLocation.coordinate.latitude)"
            let currentLong = "\(currentLocation.coordinate.longitude)"
           
            var place = ""
            geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {placemarks, error in
                if placemarks != nil {
                    let placemark = placemarks!.last
                    place = (placemark?.name)!
                } else {
                    print("Error retrieving place. Error code \(error)")
                    place = "Parts Unknown"
                }
                self.locationsArray[0].name = place
                self.locationsArray[0].coordinates = currentLat + "," + currentLong
                self.locationsArray[0].getWeather {
                    self.updateUserInterface()
                }
            })
            
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location. Error code \(error)")
    }
    
}

extension DetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationsArray[currentPage].dailyForecastArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayWeatherCell") as! DayWeatherCell
        cell.configureTableCell(dailyForecast: self.locationsArray[currentPage].dailyForecastArray[indexPath.row], timeZone: self.locationsArray[currentPage].timeZone)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80  // Return the height of the row
    }
}

extension DetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locationsArray[currentPage].hourlyForecastArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let hourlyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! HourlyWeatherCell
        hourlyCell.configureCollectionCell(hourlyForecast: self.locationsArray[currentPage].hourlyForecastArray[indexPath.row], timeZone: self.locationsArray[currentPage].timeZone)
        return hourlyCell
    }
    
}
