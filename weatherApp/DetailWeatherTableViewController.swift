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
    
    let forecastURL = "https://api.openweathermap.org/data/2.5/onecall?lat=37.62&lon=55.75&units=metric&exclude=minutely,hourly&appid=d5c5c0959386695f202511a13304a090"
    
    var daily: [Daily] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchDataAlamofire()
    }
    
    private func fetchData() {
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
    
    private func fetchDataAlamofire() {
        guard let url = URL(string: forecastURL) else { return }
        
        AF.request(url).responseDecodable(of: Forecast.self) { (response) in
            guard let weather = response.value else { return }
            DispatchQueue.main.async {
                self.daily = weather.daily
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
    
    func windDirection(degree : Float) -> String {
        let directions = ["Северный", "Северо-восточный", "Восточный", "Юго-восточный", "Южный", "Юго-западный", "Западный", "Северо-западный"]
        let i: Int = Int((degree + 33.75)/45)
        return directions[i % 8]
    }
    
    func updateWeatherIcon(condition: Int) -> String {
        let hour = 12//Calendar.current.component(.hour, from: Date())
        switch (condition) {
        case 200...232 : // шторм
            switch hour {
            case 6..<18 :
                return "storm"
            default :
                return "storm-night"
            }
            
        case 300...321 : // легкий дождь
            switch hour {
            case 6..<18 :
                return "hail"
            default :
                return "night-rain"
            }
            
        case 500...531 : // дождь
            switch hour {
            case 6..<18 :
                return "storm"
            default :
                return "night-rain"
            }
            
        case 600...622 : //снег
            switch hour {
            case 6..<18 :
                return "snowy"
            default :
                return "night-snow"
            }
            
        case 701...741 : //туман
            return "fog"
            
        case 800 : // ясно
            switch hour {
            case 6..<18 :
                return "sun"
            default :
                return "night-4"
            }
            
        case 801 : // частичная облачность
            return "cloudy-3"
            
        case 802 : //облачно
            switch hour {
            case 6..<18 :
                return "cloud"
            default :
                return "cloud-moon"
            }
            
        case 803...804 : //сильная облачность
            return "cloudy"
            
        default:
            return "windy"
        }
    }
}
