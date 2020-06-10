//
//  TableViewCell.swift
//  weatherApp
//
//  Created by Александр Уткин on 09.06.2020.
//  Copyright © 2020 Александр Уткин. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var imageWeather: UIImageView!
    @IBOutlet weak var tempDay: UILabel!
    @IBOutlet weak var tempNight: UILabel!
    @IBOutlet weak var wind: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
}
