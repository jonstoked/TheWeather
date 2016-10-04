//
//  TodayCell.swift
//  Weather
//
//  Created by Jon Stokes on 10/3/16.
//  Copyright © 2016 Jon Stokes. All rights reserved.
//

import UIKit

class TodayCell: UITableViewCell {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var tempMaxLabel: UILabel!
    @IBOutlet var tempMinLabel: UILabel!
    @IBOutlet var thumnailImageView: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!

}

class SummaryCell: UITableViewCell {
    
    @IBOutlet var thumnailImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var tempMaxLabel: UILabel!
    @IBOutlet var tempMinLabel: UILabel!
    
}
