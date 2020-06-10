//
//  DetailWeatherTableViewController.swift
//  weatherApp
//
//  Created by Александр Уткин on 01.06.2020.
//  Copyright © 2020 Александр Уткин. All rights reserved.
//

import UIKit
import Alamofire

class DetailWeatherTableViewController: UITableViewController {
        
    var daily: [Daily] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return daily.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        let imageName = updateWeatherIcon(condition: daily[indexPath.row].weather[0].id)
        cell.imageView?.image = UIImage(named: imageName)
        cell.tempDay.text = "\(daily[indexPath.row].temp.day)º"
        cell.tempNight.text = "\(daily[indexPath.row].temp.night)º"
        cell.wind.text = windDirection(degree: Float(daily[indexPath.row].windDeg))
        cell.windSpeed.text = "\(daily[indexPath.row].windSpeed) м/с"
        return cell
    }    
}

extension DetailWeatherTableViewController {
    
    func fetchData() {
        guard let url = URL(string: forecastURL) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let weather = try decoder.decode(Forecast.self, from: data)
                
                DispatchQueue.main.async {
                    self.daily = weather.daily
                    self.tableView.reloadData()
                }
            }catch let err {
                print(err)
            }
        }.resume()
    }
    
    func fetchDataAlamofire() {
        guard let url = URL(string: forecastURL) else { return }
        
        AF.request(url).responseDecodable(of: Forecast.self) { (response) in
            guard let weather = response.value else { return }
            DispatchQueue.main.async {
                self.daily = weather.daily
                self.tableView.reloadData()
            }
        }
    }
    
}
