//
//  WeatherViewController.swift
//  Weather
//
//  Created by Jon Stokes on 10/3/16.
//  Copyright © 2016 Jon Stokes. All rights reserved.
//

import UIKit

class WeatherViewController: UITableViewController {
    
    let apiKey = "37b030ce4ce471f75ad1f5919407c4a7"
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    var dataTask: NSURLSessionDataTask?
    var days = [WeatherDay]()
    @IBOutlet var footerView:UIView!  //to kill cell separators for empty cells
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dat Weather"
        getFiveDayForcast()
        footerView = UIView()
    }
    
    // we ignore the current weather API and go straight to the 5 day forecast, as it gives us 
    // all the data we need (including today's weather)
    
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
                        self.days.append(weatherDay)
                    }
                }
            }
            
        } catch let error as NSError {
            print("Error parsing results: \(error.localizedDescription)")
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let day = days[indexPath.row]
        
        //yeah, yeah.. DRY
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("todayCell", forIndexPath: indexPath) as! TodayCell
            let date = NSDate(timeIntervalSince1970: Double(day.date))
            cell.dateLabel.text = date.dayOfWeekString() + ", \(date.dateString())"
            cell.tempMaxLabel.text = String(day.temp.max) + "°"
            cell.tempMinLabel.text = String(day.temp.min) + "°"
            let imageName = WeatherDay.artNameForCode(day.iconName)
            cell.thumnailImageView.image = UIImage(named:imageName)
            cell.descriptionLabel.text = day.description
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("summaryCell", forIndexPath: indexPath) as! SummaryCell
            let date = NSDate(timeIntervalSince1970: Double(day.date))
            cell.dateLabel.text = date.dayOfWeekString()
            cell.tempMaxLabel.text = String(day.temp.max) + "°"
            cell.tempMinLabel.text = String(day.temp.min) + "°"
            let imageName = WeatherDay.iconNameForCode(day.iconName)
            cell.thumnailImageView.image = UIImage(named:imageName)
            cell.descriptionLabel.text = day.description
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 215
        } else {
            return 83
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("DetailViewController", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailViewController" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationViewController = segue.destinationViewController as! DetailViewController
                destinationViewController.day = days[indexPath.row]
            }
        }
    }

}

extension NSDate {
    
    func dayOfWeekString() -> String {
        var dayOfWeek:String = ""
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE"
        if isToday() || isTomorrow() {
            formatter.doesRelativeDateFormatting = true
            formatter.dateStyle = .ShortStyle
        }
        dayOfWeek = formatter.stringFromDate(self)
        return dayOfWeek
    }
    
    func dateString() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.stringFromDate(self)
    }
    
    func isToday() -> Bool {
        return NSCalendar.currentCalendar().isDateInToday(self)
    }
    
    func isTomorrow() -> Bool {
        return NSCalendar.currentCalendar().isDateInTomorrow(self)
    }
    
}

