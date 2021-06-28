//
//  ViewController.swift
//  MonadNetworking
//
//  Created by Nguyễn Đức Thọ on 6/28/21.
//

import UIKit

class ViewController: UIViewController {
    let button = UIButton.init(type: .system)
    private var mutableCache = NSCache<NSString, FollowerStats>()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(button)
        button.frame = CGRect.init(origin: .zero, size: CGSize.init(width: 100, height: 100))
        button.setTitle("get", for: .normal)
        button.addTarget(self, action: #selector(get), for: .touchUpInside)
        
    }
    
    @objc func get() {
        print(Stateful().followerStats(u: "thond", c: mutableCache).followerStats.userName)
    }
}
