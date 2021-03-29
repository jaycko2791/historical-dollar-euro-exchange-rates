//
//  Networking.swift
//  SegundaMano
//
//  Created by Jorge Diego on 3/26/21.
//  Copyright © 2021 cic. All rights reserved.
//

import Foundation

class Networking{
    let defaultSession = URLSession(configuration: .default)
    
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    var Exchanges :[exchange] = []
    
    typealias results = ([exchange])->Void
    typealias JSONDictionary = [String:Any]
    
    func getDates(completion:@escaping results) -> Void{
        dataTask?.cancel()
        
        if let urlComponents = URLComponents(string:"https://api.exchangeratesapi.io/history?start_at=2020-01-01&end_at=2021-01-01&base=USD&symbols=EUR"){
        
            guard let url = urlComponents.url else{return}
          
            dataTask = defaultSession.dataTask(with: url){[weak self] data,response,error in
                if let error = error {
                    self?.errorMessage += "Ups algo salio mal"
                    print(error.localizedDescription)
                }else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200{
                    self?.updateTimeseries(data)
                    DispatchQueue.main.async {
                        completion(self!.Exchanges)
                    }
                }
            }
            dataTask?.resume()
        }
    }
    
    func getDates(_ start:String,end:String,completion:@escaping results) -> Void{
        dataTask?.cancel()
        
        let urlString = "https://api.exchangeratesapi.io/history?start_at="+start+"&end_at="+end+"&base=USD&symbols=EUR"
        
        if let urlComponents = URLComponents(string:urlString){
        
            guard let url = urlComponents.url else{return}
          
            dataTask = defaultSession.dataTask(with: url){[weak self] data,response,error in
                if let error = error {
                    self?.errorMessage += "Ups algo salio mal"
                    print(error.localizedDescription)
                }else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200{
                    self?.updateTimeseries(data)
                    DispatchQueue.main.async {
                        completion(self!.Exchanges)
                    }
                }
            }
            dataTask?.resume()
        }
    }
    
    func updateTimeseries(_ data:Data){
        var response: JSONDictionary
           
        do {
            response = try (JSONSerialization.jsonObject(with: data, options: []) as? Networking.JSONDictionary)!
            
            let userDefaults = UserDefaults.standard
            userDefaults.set(response, forKey: "rates")
        } catch let parseError as NSError {
        var error = ""
          error += "JSONSerialization error: \(parseError.localizedDescription)\n"
          print(error)
          return
        }
        
        let rates = response["rates"] as! NSDictionary
        
        for (date,rate) in rates{
            if let date = date as? String, let rate = rate as? NSDictionary{
                let rate1 = rate["EUR"] as? Double
                Exchanges.append(exchange(date: date, rate: rate1!))
            }
        }
        
        Exchanges.sort(by:{ $0.dateNumb < $1.dateNumb})
        
    }
}
