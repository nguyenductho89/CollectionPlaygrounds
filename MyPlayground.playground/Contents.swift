import PlaygroundSupport
import UIKit
import Foundation

func getA(completion: (String)->()) {
    completion("getA")
}

func getB(completion: (String)->()) {
    completion("getB")
}

func getC(completion: (String)->()) {
    completion("getC")
}

func getAll() {
    getA { a in
        getB { b in
            getC { c in
                
            }
        }
    }
}

typealias ThenFunction = (data: String, next: (String)->())

func then(data: String, next: (String)->()) {
    next(data)
}

func getA(completion: (String)->(), then: ThenFunction) {
    completion("getA")
}

struct Promise<T> {
    
    var fullfill: (T)->()
    var error: (Error)->()
    init(fullfill: @escaping (T)->(),
         error: @escaping (Error)->()) {
        self.fullfill = fullfill
        self.error = error
    }
    
    func then(_ body: (T) -> Void) {
    }
}

func returnString(string: String) {
    
}

func returnError(error: Error) {
    
}

func getA() -> Promise<String> {
    return Promise { a in
        print(a)
    } error: { e in
        print(e)
    }

}

getA().then { a in
    print(a)
}

