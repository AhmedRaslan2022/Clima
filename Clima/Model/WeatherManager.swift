//
//  WeatherManager.swift
//  Clima
//
//  Created by Macintosh on 09/08/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager ,weather: WeatherModel)
    func didFaildWithError(error: Error)
}

struct WeatherManager {
    
    let WeatherUrl = "https://api.openweathermap.org/data/2.5/weather?&appid=4756bffee137b8b904deaa537389be64&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(WeatherUrl)&q=\(cityName)"
        performRequest (with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees , longitude: CLLocationDegrees){
        let urlString = "\(WeatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performRequest (with: urlString)
    }
    
    func performRequest (with urlString: String){
         if let url = URL(string: urlString) {
            let session =  URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error)in
                 if error != nil{
                     self.delegate?.didFaildWithError(error: error!)
                     return
                    }
                 if  let safeData = data {
                     if let weather = self.parseJson(safeData) {
                         delegate?.didUpdateWeather(self,weather: weather)
                     }
                }
             }
            task.resume()
        }
    }
    
    func parseJson(_ weatherData: Data)->WeatherModel? {
        let decoder = JSONDecoder()
        do {
         let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let cityName = decodedData.name
            let weather = WeatherModel(conditionId: id, cityName: cityName, temperature: temp)
            return weather
        }
        catch{
            
            return nil
        }
    }
}
