//
//  ViewController.swift
//  OvertureWorkaround
//
//  Created by Nguyen Duc Tho on 7/1/21.
//

import UIKit
import Overture
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let computeAndStringify = pipe(incr, square, String.init, {"value " + $0}, {$0 + $0}, {print($0)})
        print(type(of: computeAndStringify))
        
        [1, 2, 3].map(computeAndStringify)
}

    func incr(_ x: Int) -> Int {
        return x + 1
    }
    
    func square(_ x: Int) -> Int {
        return x * x
    }

}
