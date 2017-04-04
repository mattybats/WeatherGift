//
//  HourlyWeatherCell.swift
//  Weather Gift
//
//  Created by John Gallaugher on 3/25/17.
//  Copyright © 2017 Gallaugher. All rights reserved.
//

import UIKit

class HourlyWeatherCell: UICollectionViewCell {
    
    @IBOutlet weak var hourlyTime: UILabel!
    @IBOutlet weak var hourlyTemp: UILabel!
    @IBOutlet weak var hourlyIcon: UIImageView!
    @IBOutlet weak var hourlyPrecipProb: UILabel!
    @IBOutlet weak var rainDropIcon: UIImageView!
    
    
    func configureCollectionCell(hourlyForecast: WeatherLocation.HourlyForecast, timeZone: String) {
        hourlyTemp.text = String(format: "%2.f", hourlyForecast.hourlyTemp) + "°"
        hourlyIcon.image = UIImage(named: "small-" + hourlyForecast.hourlyIcon)
        
        hourlyPrecipProb.text = String(format: "%2.f", hourlyForecast.hourlyPrecipProb * 100) + "%"
        let isHidden = !(hourlyForecast.hourlyPrecipProb >= 0.30 || hourlyForecast.hourlyIcon == "rain")
        hourlyPrecipProb.isHidden = isHidden
        rainDropIcon.isHidden = isHidden
        
        let usableDate =  Date(timeIntervalSince1970: hourlyForecast.hourlyTime)
        let hourlyTimeZone = TimeZone(identifier: timeZone)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ha"
        dateFormatter.timeZone = hourlyTimeZone
        let hour = dateFormatter.string(from: usableDate)
        hourlyTime.text = hour
    }
}
