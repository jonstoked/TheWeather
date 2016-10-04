//
//  DetailViewController.swift
//  Weather
//
//  Created by Jon Stokes on 10/3/16.
//  Copyright © 2016 Jon Stokes. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var tempMaxLabel: UILabel!
    @IBOutlet var tempMinLabel: UILabel!
    @IBOutlet var thumnailImageView: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var pressureLabel: UILabel!
    @IBOutlet var windLabel: UILabel!
    
    var day:WeatherDay!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let date = NSDate(timeIntervalSince1970: Double(day.date))
        dayLabel.text = date.dayOfWeekString()
        dateLabel.text = date.dateString()
        tempMaxLabel.text = String(day.temp.max) + "°"
        tempMinLabel.text = String(day.temp.min) + "°"
        let imageName = WeatherDay.artNameForCode(day.iconName)
        thumnailImageView.image = UIImage(named:imageName)
        descriptionLabel.text = day.description
        
        humidityLabel.text = "Humidity: \(day.humidity) %"
        pressureLabel.text = "Pressure: \(day.pressure) hPa"
        windLabel.text = "Wind: \(day.wind.speed) km/h \(WeatherDay.directionFromAngle(Int(day.wind.angle)))"
        
    }
    
}
