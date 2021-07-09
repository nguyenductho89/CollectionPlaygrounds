//
//  Materalize.swift
//  RxSwiftWorkaround
//
//  Created by Nguyen Duc Tho on 7/9/21.
//

import UIKit
import RxSwift

enum RequestError: Error {
    case unknown
}

func requestToken() -> Observable<String> {
    
    return Observable.create { observer in
        
        let success = true
        
        if success {
            observer.onNext("MyTokenValue")
            observer.onCompleted()
        } else {
            observer.onError(RequestError.unknown)
        }
        
        return Disposables.create()
    }
}

func requestData(token: String) -> Observable<[String: Any]> {
    
    return Observable<[String: Any]>.create { observer in
        
        let success = false
        
        if success {
            observer.onNext(["uid": 007])
            observer.onCompleted()
        } else {
            observer.onError(RequestError.unknown)
        }
        
        return Disposables.create()
    }
    .map { (data: [String: Any]) in
        var newData = data
        newData["token"] = token
        return newData
    }
}

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        requestToken()                      // () -> Observable<String>
            .debug("\nthond: 1# token", trimOutput: true)
            .flatMapLatest(requestData)     // Observable<String> -> Observable<[String: Any]>
            .debug("\nthond: 2# requestData", trimOutput: true)
            .materialize()                  // Observable<[String: Any]> -> Observable<Event<[String: Any]>>
            .debug("\nthond: 3# materialize", trimOutput: true)
            .subscribe(onNext: { event in
                switch event {
                    case .next(let dictionary):
                        print("onNext:", dictionary)
                    case .error(let error as RequestError):
                        print("onRequestError:", error)
                    case .error(let error):
                        print("onOtherError:", error)
                    case .completed:
                        print("onCompleted")
                }
            })
            .disposed(by: disposeBag)
        
        requestToken()                      // () -> Observable<String>
            .debug("\nthond: 1# token", trimOutput: true)
            .flatMapLatest(requestData)     // Observable<String> -> Observable<[String: Any]>
            .debug("\nthond: 2# requestData", trimOutput: true)
            .subscribe(onNext: { dictionary in
                print("onNext:", dictionary)
            }, onError: { error in
                print("onRequestError:", error)
            })
            .disposed(by: disposeBag)
    }
}
