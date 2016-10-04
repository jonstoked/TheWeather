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
    @IBOutlet var footerView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFiveDayForcast()
        footerView = UIView()
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
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("todayCell", forIndexPath: indexPath) as! TodayCell
            let date = NSDate(timeIntervalSince1970: Double(day.date))
            cell.dateLabel.text = date.dayOfWeek()
            cell.tempMaxLabel.text = String(day.temp.max)
            cell.tempMinLabel.text = String(day.temp.min)
            let imageName = self.artNameForCode(day.iconName)
            cell.thumnailImageView.image = UIImage(named:imageName)
            cell.descriptionLabel.text = day.description
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("summaryCell", forIndexPath: indexPath) as! SummaryCell
            let date = NSDate(timeIntervalSince1970: Double(day.date))
            cell.dateLabel.text = date.dayOfWeek()
            cell.tempMaxLabel.text = String(day.temp.max)
            cell.tempMinLabel.text = String(day.temp.min)
            let imageName = self.iconNameForCode(day.iconName)
            cell.thumnailImageView.image = UIImage(named:imageName)
            cell.descriptionLabel.text = day.description
            return cell
        }
        
        
        
        
//        let cell = tableView.dequeueReusableCellWithIdentifier("videoCell", forIndexPath: indexPath) as! VideoCell
//        let video = videos[indexPath.row]
//        cell.label.text = video.title
//        let url = NSURL(string: video.thumbnailUrl!)!
//        cell.thumnailImageView.kf_setImageWithURL(url)
//        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 215
        } else {
            return 83
        }
    }
    
    func dayAndDateFromUTC(utc: Double) -> String {
        let date = NSDate(timeIntervalSince1970: utc)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM d"
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .ShortStyle

        return formatter.stringFromDate(date)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let video = videos[indexPath.row]
//        let videoViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: video.videoId)
//        presentViewController(videoViewController, animated: true, completion:nil)
        
    }
    
    func artNameForCode(code: String) -> String {
        let digits = code.substringToIndex(code.startIndex.advancedBy(2))
        return "art_" + iconTypeForCode(digits)
    }
    
    func iconNameForCode(code: String) -> String {
        let digits = code.substringToIndex(code.startIndex.advancedBy(2))
        return "ic_" + iconTypeForCode(digits)
    }
    
    func iconTypeForCode(code: String) -> String {
        var name:String
        switch code {
        case "01":
            name = "clear"
        case "02":
            name = "light_clouds"
        case "03", "04":
            name = "clouds"
        case "09":
            name = "light_rain"
        case "10":
            name = "rain"
        case "11":
            name = "storm"
        case "13":
            name = "snow"
        case "50":
            name = "fog"
        default:
            name = ""
        }
        return name
    }
    
    

}

extension NSDate {
    
    func dayOfWeek() -> String {
        var dayOfWeek:String = ""
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE"
        if isToday() || isTomorrow() {
            formatter.doesRelativeDateFormatting = true
            formatter.dateStyle = .ShortStyle
        }
        dayOfWeek = formatter.stringFromDate(self)
        
        if isToday() {
            dayOfWeek += ", \(self.dateString())"
        }
        
        return dayOfWeek
    }
    
    func isToday() -> Bool {
        return NSCalendar.currentCalendar().isDateInToday(self)
    }
    
    func isTomorrow() -> Bool {
        return NSCalendar.currentCalendar().isDateInTomorrow(self)
    }
    
    func dateString() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.stringFromDate(self)
    }
}

