//
//  CombiningObservables.swift
//  RxSwiftWorkaround
//
//  Created by Nguyen Duc Tho on 7/9/21.
//

import Foundation
import UIKit
import RxSwift
import Charts
import SnapKit

class ViewController: UIViewController {
    
    lazy var chartView: LineChartView = {
        let v = LineChartView(frame: .zero)
        v.data = LineChartData()
        return v
    }()
    
    lazy var source1Data: LineChartDataSet = {
        let d = LineChartDataSet(entries: [ChartDataEntry](), label: "Source 1")
        d.colors = [.systemRed]
        return d
    }()
    
    lazy var source2Data: LineChartDataSet = {
        let d = LineChartDataSet(entries: [ChartDataEntry](), label: "Source 2")
        d.colors = [.systemBlue]
        return d
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(chartView)
        chartView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view)
            make.centerY.equalToSuperview()
            make.height.equalTo(200)
        }
        chartView.data?.dataSets.append(source1Data)
        chartView.data?.dataSets.append(source2Data)
        self.chartView.data?.appendEntry(ChartDataEntry(x: Double(0), y: 0), toDataSet: 0)
        self.chartView.data?.appendEntry(ChartDataEntry(x: Double(0), y: 1), toDataSet: 1)
        self.chartView.notifyDataSetChanged()
            
        let source1 = Observable<String>.create { observer -> Disposable in
            Timer.scheduledTimer(withTimeInterval: Double.random(in: 5...25), repeats: true) { _ in
                observer.onNext(Date().debugDescription)
            }
            return Disposables.create()
        }

        let source2 = Observable<Int>.create { observer -> Disposable in
            Timer.scheduledTimer(withTimeInterval: Double.random(in: 5...25), repeats: true) { _ in
                observer.onNext(Int.random(in: 0...100))
            }
            return Disposables.create()
        }
        
        source2
            .subscribe(on: MainScheduler.instance)
            .subscribe { s in
            let entries = self.chartView.data?.dataSet(at: 1)?.entryCount ?? 0
            self.chartView.data?.appendEntry(ChartDataEntry(x: Double(entries+1), y: 1), toDataSet: 1)
            self.chartView.moveViewToX(Double(entries+1))
            self.chartView.notifyDataSetChanged()
        }
        source1
            .subscribe(on: MainScheduler.instance)
            .subscribe { s in
                let entries = self.chartView.data?.dataSet(at: 0)?.entryCount ?? 0
                self.chartView.data?.appendEntry(ChartDataEntry(x: Double(entries+1), y: 0), toDataSet: 0)
                self.chartView.moveViewToX(Double(entries+1))
                self.chartView.notifyDataSetChanged()
            }
    }
}
