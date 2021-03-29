//
//  Exvhange.swift
//  SegundaMano
//
//  Created by Jorge Diego on 3/26/21.
//  Copyright © 2021 cic. All rights reserved.
//

import Foundation
import UIKit

class exchange{
    var base:String = "USD"
    var change:String = "EUR"
    var rate = 0.0
    var date = "String"
    var dateNumb = 0
    
    
    init(date: String, rate: Double){
        self.date = date
        self.rate = rate
        self.dateNumb = convertdatetoInt(date)
    }
    
    func convertdatetoInt(_ date:String)->Int{
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd"
        let time = formater.date(from: date)
        let timeInt = time!.timeIntervalSince1970
        return Int(timeInt)
    }
}
