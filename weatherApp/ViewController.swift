//
//  ViewController.swift
//  weatherApp
//
//  Created by Александр Уткин on 01.06.2020.
//  Copyright © 2020 Александр Уткин. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    let url = "https://api.openweathermap.org/data/2.5/weather?q=Moscow&units=metric&appid="
    let key = "d5c5c0959386695f202511a13304a090"
    
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var imageWeather: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var speedWind: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var cloudLabel: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var secondStack: UIStackView!
    @IBOutlet weak var firstStack: UIStackView!
    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var labelSeparate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstStack.isHidden = true
        secondStack.isHidden = true
        buttonsStack.isHidden = true
        labelSeparate.isHidden = true
        activity.isHidden = false
        activity.startAnimating()
        
    }
    
    private func fetchData(url: String) {
        
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let weather = try decoder.decode(Model.self, from: data)
                
                DispatchQueue.main.async {
                    
                    self.setupView(weather: weather)
                    self.activity.isHidden = true
                    self.activity.stopAnimating()
                    self.firstStack.isHidden = false
                    self.secondStack.isHidden = false
                    self.buttonsStack.isHidden = false
                    self.labelSeparate.isHidden = false
                }
            }catch let err {
                print(err)
            }
        }.resume()
    }
    
    func fetchDataAlamofire(url: String) {
        
        guard let url = URL(string: url) else { return }
        
        AF.request(url).responseDecodable(of: Model.self) { (response) in
            guard let weather = response.value else { return }
            DispatchQueue.main.async {
                self.setupView(weather: weather)
                self.activity.isHidden = true
                self.activity.stopAnimating()
                self.firstStack.isHidden = false
                self.secondStack.isHidden = false
                self.buttonsStack.isHidden = false
                self.labelSeparate.isHidden = false
            }
        }
    }
    
    private func setupView(weather: Model) {
        city.text = "Москва"
        let condition = weather.weather[0].id
        switch condition {
        case 200...232:
            conditionLabel.text = "Шторм"
        case 300...321:
            conditionLabel.text = "Легкий дождь"
        case 500...531:
            conditionLabel.text = "Дождь"
        case 600...622:
            conditionLabel.text = "Снег"
        case 701...741:
            conditionLabel.text = "Туман"
        case 800:
            conditionLabel.text = "Ясно"
        case 801:
            conditionLabel.text = "Частичная облачность"
        case 802:
            conditionLabel.text = "Облачно"
        case 803...804:
            conditionLabel.text = "Сильная облачность"
        default:
            conditionLabel.text = ""
        }
        let nameImage = updateWeatherIcon(condition: condition)
        imageWeather.image = UIImage(named: nameImage)
        let windString = windDirection(degree: Float(weather.wind.deg))
        
        tempLabel.text = "\(Int(weather.main.temp))º"
        windLabel.text = "\(weather.wind.speed) м/с"
        speedWind.text = String(windString)
        humidityLabel.text = "\(weather.main.humidity)%"
        cloudLabel.text = String(weather.clouds.all)
    }
    
    func windDirection(degree : Float) -> String {
        let directions = ["Северный", "Северо-восточный", "Восточный", "Юго-восточный", "Южный", "Юго-западный", "Западный", "Северо-западный"]
        let i: Int = Int((degree + 33.75)/45)
        return directions[i % 8]
    }
    
    func updateWeatherIcon(condition: Int) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
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
    @IBAction func urlSessionButton(_ sender: Any) {
        firstStack.isHidden = true
        secondStack.isHidden = true
        buttonsStack.isHidden = true
        labelSeparate.isHidden = true
        activity.isHidden = false
        activity.startAnimating()
        let fullURL = url + key
        fetchData(url: fullURL)
    }
    
    @IBAction func alamofireButton(_ sender: Any) {
        firstStack.isHidden = true
        secondStack.isHidden = true
        buttonsStack.isHidden = true
        labelSeparate.isHidden = true
        activity.isHidden = false
        activity.startAnimating()
        let fullURL = url + key
        fetchDataAlamofire(url: fullURL)
    }
}

