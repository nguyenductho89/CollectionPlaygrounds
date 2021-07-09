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
    enum Lines: Int {
        case source1
        case source2
        
        var defaultY: Double {
            switch self {
            case .source1:
                return 1.0
            case .source2:
                return 1.0
            }
        }
        
        var dataSetIndex: Int {
            switch self {
            case .source1:
                return 0
            case .source2:
                return 0
            }
        }
        
        var firstEntry: ChartDataEntry {
            return ChartDataEntry(x: Double(0), y: defaultY)
        }
    }
    var disposeBAg = DisposeBag.init()
    let currentTime = PublishSubject<Void>.init()
    var numberCount = 0
    lazy var chartView1: LineChartView = {
        let v = LineChartView(frame: .zero)
        v.data = LineChartData()
        v.leftAxis.axisMaximum = 1.1
        v.leftAxis.axisMinimum = 1.0 - 0.1
        //v.xAxis.enabled = false
        v.xAxis.drawGridLinesEnabled = false
        v.xAxis.drawAxisLineEnabled = false
        v.xAxis.granularity = 1.0
        v.leftAxis.enabled = false
        v.rightAxis.enabled = false
        v.legend.form = .square
        v.xAxis.axisMinimum = 0.0
        v.dragEnabled = true
        return v
    }()
    lazy var chartView2: LineChartView = {
        let v = LineChartView(frame: .zero)
        v.data = LineChartData()
        v.leftAxis.axisMaximum = 1.1
        v.leftAxis.axisMinimum = 1.0 - 0.1
        v.xAxis.enabled = false
        v.xAxis.granularity = 1.0
        v.leftAxis.enabled = false
        v.rightAxis.enabled = false
        v.legend.form = .square
        v.xAxis.axisMinimum = 0.0
        v.dragEnabled = true
        return v
    }()
    
    lazy var source1Data: LineChartDataSet = {
        let d = LineChartDataSet(entries: [ChartDataEntry](), label: "Source 1")
        d.colors = [.systemRed]
        d.mode = .cubicBezier
        d.circleColors = [.clear]
        d.circleHoleColor = .clear
        d.drawValuesEnabled = false
        return d
    }()
    
    lazy var source2Data: LineChartDataSet = {
        let d = LineChartDataSet(entries: [ChartDataEntry](), label: "Source 2")
        d.colors = [.systemBlue]
        d.mode = .cubicBezier
        d.circleColors = [.clear]
        d.circleHoleColor = .clear
        d.drawValuesEnabled = false
        return d
    }()
    
    lazy var stopButton: UIButton = {
        let b = UIButton.init(type: .custom)
        b.addTarget(self, action: #selector(stop), for: .touchUpInside)
        b.titleLabel?.text = "Stop"
        b.backgroundColor = .systemRed
        return b
    }()
    
    @objc func stop() {
        self.disposeBAg = DisposeBag.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(chartView1)
        self.view.addSubview(chartView2)
        self.view.addSubview(stopButton)
        stopButton.snp.makeConstraints { make in
            make.top.equalTo(self.view).offset(30)
            make.centerX.equalTo(self.view)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        chartView1.snp.makeConstraints { make in
            make.top.equalTo(stopButton.snp.bottom).offset(30)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(30+20)
        }
        chartView2.snp.makeConstraints { make in
            make.top.equalTo(chartView1.snp.bottom)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(30+20)
        }
        chartView1.data?.dataSets.append(source1Data)
        chartView2.data?.dataSets.append(source2Data)
        self.chartView1.data?.appendEntry(Lines.source1.firstEntry,
                                          toDataSet: Lines.source1.dataSetIndex)
        self.chartView2.data?.appendEntry(Lines.source2.firstEntry,
                                          toDataSet: Lines.source2.dataSetIndex)
        
        let source1 = Observable<String>.create { observer -> Disposable in
            Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                observer.onNext(Date().debugDescription)
            }
            return Disposables.create()
        }
        
        let source2 = Observable<Int>.create { observer -> Disposable in
            DispatchQueue.init(label: "thond").asyncAfter(deadline: .now() + 1) {
                DispatchQueue.main.async {
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                        observer.onNext(Int.random(in: 0...100))
                    }
                }
            }
            return Disposables.create()
        }
        
        source2
            .subscribe(on: MainScheduler.instance)
            .do(onNext: { _ in
                self.currentTime.onNext(())
            })
            .debug("@@@@@@@ source2", trimOutput: true)
            .subscribe { s in
                self.chartView2.data?.appendEntry(ChartDataEntry(x: Double(self.numberCount), y: Lines.source2.defaultY,icon: UIColor.systemRed.image(.init(width: 20, height: 20))),
                                                 toDataSet: Lines.source2.dataSetIndex)
                self.chartView1.data?.appendEntry(ChartDataEntry(x: Double(self.numberCount), y: Lines.source1.defaultY,icon: UIColor.systemRed.image(.init(width: 1, height: 1))),
                                                 toDataSet: Lines.source1.dataSetIndex)
                self.chartView1.moveViewToX(Double(self.numberCount + 10))
                self.chartView2.moveViewToX(Double(self.numberCount + 10))
                self.chartView2.notifyDataSetChanged()
                self.chartView1.notifyDataSetChanged()
            }
            .disposed(by: disposeBAg)
        
        source1
            .do(onNext: { _ in
                self.currentTime.onNext(())
            })
            .debug("!!!!!!!! source1", trimOutput: true)
            .subscribe(on: MainScheduler.instance)
            .subscribe { s in
                self.chartView1.data?.appendEntry(ChartDataEntry(x: Double(self.numberCount), y: Lines.source1.defaultY,icon: UIColor.systemBlue.image(.init(width: 20, height: 20))),
                                                 toDataSet: Lines.source1.dataSetIndex)
                self.chartView2.data?.appendEntry(ChartDataEntry(x: Double(self.numberCount), y: Lines.source2.defaultY, icon: UIColor.systemBlue.image(.init(width: 1, height: 1))),
                                                 toDataSet: Lines.source2.dataSetIndex)
                self.chartView1.moveViewToX(Double(self.numberCount + 10))
                self.chartView2.moveViewToX(Double(self.numberCount + 10))
                self.chartView1.notifyDataSetChanged()
                self.chartView2.notifyDataSetChanged()
            }
            .disposed(by: disposeBAg)
        
        currentTime
            .subscribe { (_) in
            self.numberCount += 1
                self.chartView1.xAxis.axisMinimum = Double(self.numberCount - 10)
                self.chartView2.xAxis.axisMinimum = Double(self.numberCount - 10)
        }
        .disposed(by: disposeBAg)
        
    }
}

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
