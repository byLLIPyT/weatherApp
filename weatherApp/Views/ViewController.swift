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
        hideUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! DetailWeatherTableViewController
        if segue.identifier == "Session" {
            vc.fetchData()
        }
        if segue.identifier == "Alamofire" {
            vc.fetchDataAlamofire()
        }
    }
    
    @IBAction func urlSessionButton(_ sender: Any) {
        hideUI()
        fetchData(url: fullURL)
    }
    
    @IBAction func alamofireButton(_ sender: Any) {
        hideUI()
        fetchDataAlamofire(url: fullURL)
    }
}

extension ViewController {
    func hideUI() {
        
        firstStack.isHidden = true
        secondStack.isHidden = true
        buttonsStack.isHidden = true
        labelSeparate.isHidden = true
        activity.isHidden = false
        activity.startAnimating()
    }
    
    func showUI() {
        
        self.activity.isHidden = true
        self.activity.stopAnimating()
        self.firstStack.isHidden = false
        self.secondStack.isHidden = false
        self.buttonsStack.isHidden = false
        self.labelSeparate.isHidden = false
    }
    
    func setupView(weather: Model) {
        
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
    
    func fetchData(url: String) {
        
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let weather = try decoder.decode(Model.self, from: data)
                
                DispatchQueue.main.async {
                    
                    self.setupView(weather: weather)
                    self.showUI()
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
                self.showUI()
            }
        }
    }
}


