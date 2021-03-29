//
//  ViewController.swift
//  SegundaMano
//
//  Created by Jorge Diego on 3/25/21.
//  Copyright © 2021 cic. All rights reserved.
//

import UIKit
import Charts
import TinyConstraints
import Network

class ViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var titlechart: UILabel!
    @IBOutlet weak var field1: UITextField!
    @IBOutlet weak var field2: UITextField!
    
    let microService = Networking()
    var exchanges:[exchange] = []
    
    lazy var lineCharView:LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .white
        chartView.rightAxis.enabled = false
        
        let yAxis =  chartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .darkGray
        yAxis.axisLineColor = .darkGray
        yAxis.labelPosition = .outsideChart
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        chartView.xAxis.labelTextColor = .darkGray
        chartView.xAxis.axisLineColor = .darkGray
        
        chartView.animate(xAxisDuration: 2.5)
        
        return chartView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDatafromCache()
    
        
        microService.getDates(){[weak self] results in
            self?.exchanges = results
            self?.setData()
        }
        
        view.addSubview(lineCharView)
        lineCharView.centerInSuperview()
        lineCharView.width(to: view)
        lineCharView.heightToWidth(of: view)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
    }
    
    func setData(){
        var dataEntries: [ChartDataEntry] = []
        var x = 0.0
        
        for exc in exchanges{
            let dataEntry = ChartDataEntry(x: x, y:exc.rate)
            dataEntries.append(dataEntry)
            x+=1.0
        }
        
        let set1 = LineChartDataSet(entries:dataEntries, label:"Dollar-euro echange rate")
        
        set1.mode = .cubicBezier
        set1.lineWidth = 3
        set1.setColor(.green)
        set1.fill = Fill(color: .green)
        set1.fillAlpha = 0.4
        set1.drawFilledEnabled = true
        set1.drawCirclesEnabled = false
        
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineCharView.data = data
        lineCharView.animate(xAxisDuration: 2.5)
    }
    
    func setDatafromCache()->Void{
        
        let userDefaults = UserDefaults.standard
        if let cachedata = userDefaults.object(forKey: "rates") as? Dictionary<String,Any>{
            let rates = cachedata["rates"] as! NSDictionary
            
            for (date,rate) in rates{
                if let date = date as? String, let rate = rate as? NSDictionary{
                    let rate1 = rate["EUR"] as? Double
                    exchanges.append(exchange(date: date, rate: rate1!))
                }
            }
            exchanges.sort(by:{ $0.dateNumb < $1.dateNumb})
        }
        
        setData()
    }
    
    
    @IBAction func Update(_ sender: Any) {
        let start: String = field1.text!
        let end: String = field2.text!
        
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        if dateFormatterGet.date(from: start) != nil && dateFormatterGet.date(from: end) != nil{
            self.titlechart.text = "from "+start+" to "+end
            
            
            microService.getDates(start, end: end){[weak self] results in
                self?.exchanges = results
                self?.setData()
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Inserta una fecha valida", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            self.present(alert, animated: true)
        }
        
        
    
    }
    
//    let yValues:[ChartDataEntry] = [
//        ChartDataEntry(x: 0.0, y:10.0),
//        ChartDataEntry(x: 1.0, y:5.0),
//        ChartDataEntry(x: 2.0, y:10.0),
//        ChartDataEntry(x: 3.0, y:7.0),
//        ChartDataEntry(x: 4.0, y:10.0),
//        ChartDataEntry(x: 5.0, y:10.0),
//        ChartDataEntry(x: 6.0, y:10.0),
//        ChartDataEntry(x: 7.0, y:10.0),
//        ChartDataEntry(x: 8.0, y:10.0),
//    ]

}

