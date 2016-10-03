//
//  ViewController.swift
//  Weather
//
//  Created by Jon Stokes on 10/3/16.
//  Copyright © 2016 Jon Stokes. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let apiKey = "37b030ce4ce471f75ad1f5919407c4a7"
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    var dataTask: NSURLSessionDataTask?
    var days = [WeatherDay]()

    override func viewDidLoad() {
        super.viewDidLoad()
        getFiveDayForcast()
    }
    
    func getFiveDayForcast() {
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let url = NSURL(string: "http://api.openweathermap.org/data/2.5/forecast/daily?units=imperial&cnt=5&lat=33.749&lon=-84.387978&appid=\(apiKey)")
        
        dataTask = defaultSession.dataTaskWithURL(url!) {
            data, response, error in
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    self.updateWeather(data)
                }
            }
        }
        dataTask?.resume()
    }
    
    func updateWeather(data: NSData?) {
        days.removeAll()
        
        do {
            
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
            print(json)
            
            if let days = json["list"] as? [[String: AnyObject]] {
                for day in days {
                    if let weatherDay = WeatherDay(json: day) {
//                        print(weatherDay)
                        self.days.append(weatherDay)
                    }
                }
            }
            
            
            

//            if let data = data, response = try NSJSONSerialization.JSONObjectWithData(data, options:[]) as? [String:Any] {
//                
//                // Get the results array
//                if let array = response["list"] as? [Any] {
//                    
//                }
//            }
            
                    
                    
                    
                    
                    
                    
                    
//                    for item in array as! [String:Any] {
//                        if let day = WeatherDay(json:item) {
//                        
//                        
////                        if let trackDictonary = trackDictonary as? [String: AnyObject], previewUrl = trackDictonary["previewUrl"] as? String {
//                            // Parse the search result
////                            let name = trackDictonary["trackName"] as? String
////                            let artist = trackDictonary["artistName"] as? String
////                            searchResults.append(Track(name: name, artist: artist, previewUrl: previewUrl))
//                        } else {
//                            print("Not a dictionary")
//                        }
//                    }
//                } else {
//                    print("Results key not found in dictionary")
//                }
//            } else {
//                print("JSON Error")
//            }
        } catch let error as NSError {
            print("Error parsing results: \(error.localizedDescription)")
        }
        
        dispatch_async(dispatch_get_main_queue()) {
//            self.tableView.reloadData()
        }
    }

}

struct WeatherDay {
    
//    "list": [
//    {
//    "dt": 1475514000,
//    "temp": {
//    "day": 82.04,
//    "min": 57.67,
//    "max": 82.29,
//    "night": 60.94,
//    "eve": 72.01,
//    "morn": 57.67
//    },
//    "pressure": 988.54,
//    "humidity": 46,
//    "weather": [
//    {
//    "id": 801,
//    "main": "Clouds",
//    "description": "few clouds",
//    "icon": "02d"
//    }
//    ],
//    "speed": 3.62,
//    "deg": 151,
//    "clouds": 12
//    },
    
    let date:Int
    let temp: (min:Int, max:Int)
    let iconName:String
    let description:String
    let humidity:Int // percentage
    let pressure:Int // hPA
    let wind: (speed: Float, angle: Int)  // km/h NW (for example)
    
    init?(json: [String: AnyObject]) {
        guard let date = json["dt"] as? Int,
        
            let temp = json["temp"] as? [String: AnyObject],
            let tempMin = temp["min"] as? Int,
            let tempMax = temp["max"] as? Int,

            let weather = json["weather"] as? [[String: AnyObject]],
            let iconName = weather[0]["icon"] as? String,
            let description = weather[0]["main"] as? String,

            let humidity = json["humidity"] as? Int,
            let pressure = json["pressure"] as? Int,
            
            let windSpeed = json["speed"] as? Float,
            let windAngle = json["deg"] as? Int
        
        else {
            return nil
        }
        
        self.temp = (tempMin,tempMax)
        self.date = date
        self.iconName = iconName
        self.description = description
        self.humidity = humidity
        self.pressure = pressure
        self.wind = (windSpeed,windAngle)

//        let direction1 = directionFromAngle(90)
//        let direction2 = directionFromAngle(30)
//        let direction3 = directionFromAngle(180)
        
    }
    
    func directionFromAngle(angle:Int) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index:Int = ((angle + 22) / 45) % directions.count
        return directions[index]
    }
}

