//
//  ViewController.swift
//  BowWorkaround
//
//  Created by Nguyễn Đức Thọ on 6/28/21.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let a: Int? = 3
        let b: String? = "ba"
        let aMap = a.map {$0}
        let aFlatMap = a.flatMap {$0}
        let aMapThenb = a.map { x in
            b.map { y  in
                return "\(x) \(y)"
            }
        }
        let aFlatMapThenb1 = a.flatMap { x in
            b.flatMap { y  in
                return "\(x) \(y)"
            }
        }
        let aFlatMapThenb2 = a.flatMap { x in
            b.map { y  in
                return "\(x) \(y)"
            }
        }
        // Do any additional setup after loading the view.
        let e = join_flatMap(Optional(1), Optional(2), Optional("t"))
        switch e {
            case .some(let a):
                print(a)
            default:break
        }
        
        let f = [[1], [2,3], [[4]]]
        let f1 = f.flatMap {$0}
    }
    
    func join_flatMap(_ a: Int?, _ b: Double?, _ c: String?) -> String? {
        a.flatMap { x in
            b.flatMap { y in
                c.flatMap { z in
                    "\(x), \(y), \(z)"
                }
            }
        }
    }
}
