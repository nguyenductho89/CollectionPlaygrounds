//
//  ViewController.swift
//  SwiftBow
//
//  Created by Nguyen Duc Tho on 7/1/21.
//

import UIKit
import Bow
import BowEffects

class ViewController: UIViewController {
    let request: IO<Error, (response: URLResponse, data: Data)> = URLSession.shared.dataTaskIO(with: URL(string: "https://bow-swift.io")!)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Providing production implementations
        let prodEnv = Environment(database: ProductionDatabase(),
                                  api: ProductionAPI())
        cacheUser(by: "12345").provide(prodEnv)
        
        // Providing testing implementations
        let testEnv = Environment(database: TestDatabase(),
                                  api: TestAPI())
        cacheUser(by: "12345").provide(testEnv)
        
        let stringIO: IO<Error, String> =
            request.map { result in result.data }
            .map { data in String(data: data, encoding: .utf8) ?? "" }^
    }
    
    func greet(name: String) {
        print("Hello \(name)!")
    }
    
    func homePage(callback: @escaping (Either<Error, Data>) -> ()) {
        if let url = URL(string: "https://bow-swift.io") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    callback(.right(data))
                } else if let error = error {
                    callback(.left(error))
                }
            }.resume()
        }
    }
    
    func greetIO(name: String) -> IO<Never, Void> {
        return IO.invoke { self.greet(name: name) }
    }
    
    func homePageIO() -> IO<Error, Data> {
        return IO.async { callback in
            if let url = URL(string: "https://bow-swift.io") {
                URLSession.shared.dataTask(with: url) { data, _, error in
                    if let data = data {
                        callback(.right(data))
                    } else if let error = error {
                        callback(.left(error))
                    }
                }.resume()
            }
        }^
    }
    
    func cacheUser(by id: String) -> EnvIO<Environment, Error, ()> {
        return EnvIO { environment in
            environment.api
                .getUser(by: id)
                .flatMap { user in environment.database.save(user: user) }
        }
    }
}

struct User {
    let name: String
}

struct Environment {
    let database: Database
    let api: API
}

protocol API {
    func getUser(by id: String) -> IO<Error, User>
}

protocol Database {
    func save(user: User) -> IO<Error, Void>
}

struct ProductionDatabase: Database {
    func save(user: User) -> IO<Error, Void> {
        return IO.init()
    }
}

struct TestDatabase: Database {
    func save(user: User) -> IO<Error, Void> {
        return IO.init()
    }
}

struct ProductionAPI: API {
    func getUser(by id: String) -> IO<Error, User> {
        return IO.init()
    }
}

struct TestAPI: API {
    func getUser(by id: String) -> IO<Error, User> {
        return IO.init()
    }
}
