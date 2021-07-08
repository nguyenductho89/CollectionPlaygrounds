//
//  RxExtension.swift
//  s
//
//  Created by Nguyen Duc Tho on 7/5/21.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: UIViewController {
    
    var viewDidLoad: Observable<Void> {
        return self.sentMessage(#selector(Base.viewDidLoad)).map { _ in
            Void()
        }
    }
    
    var viewWillAppear: Observable<Bool> {
        return self.sentMessage(#selector(Base.viewWillAppear)).map {
            $0.first as? Bool ?? false
        }
    }
    
    var viewWillAppearFirst: Observable<Void> {
        return viewWillAppear.take(1).map { _ in }
    }
    
    var viewDidAppear: Observable<Bool> {
        return self.sentMessage(#selector(Base.viewDidAppear)).map {
            $0.first as? Bool ?? false
        }
    }
    
    var viewWillDisappear: Observable<Bool> {
        return self.sentMessage(#selector(Base.viewWillDisappear)).map {
            $0.first as? Bool ?? false
        }
    }
    var viewDidDisappear: Observable<Bool> {
        return self.sentMessage(#selector(Base.viewDidDisappear)).map {
            $0.first as? Bool ?? false
        }
    }
    
    var viewWillLayoutSubviews: Observable<Void> {
        return self.sentMessage(#selector(Base.viewWillLayoutSubviews)).map { _ in
            Void()
        }
    }
    
    var viewDidLayoutSubviews: Observable<Void> {
        return self.sentMessage(#selector(Base.viewDidLayoutSubviews)).map { _ in
            Void()
        }
    }
    
    var willMoveToParentViewController: Observable<UIViewController?> {
        return self.sentMessage(#selector(Base.willMove)).map {
            $0.first as? UIViewController
        }
    }
    
    var keyboardHeight: Observable<CGFloat> {
        Observable.from([
            NotificationCenter.default.rx
                .notification(UIResponder.keyboardWillShowNotification)
                .map {($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0},
            NotificationCenter.default.rx
                .notification(UIResponder.keyboardWillHideNotification)
                .map {_ in 0}
        ])
        .merge()
        .observe(on: MainScheduler.instance)
        .debug("thond", trimOutput: true)
        .do(onDispose: {
            NotificationCenter.default.removeObserver(self)
        })
    }
}

extension UIView {
    func findTextfield() -> [UITextField] {
        return self.subviews.flatMap {view -> [UITextField] in
            guard view is UITextField else {
                return view.findTextfield()
            }
            return [view as? UITextField].compactMap {$0}
        }
    }
    
    func topViewOfType<T: UIView>(_ type: T.Type) -> T? {
        if self is T {return self as? T}
        for view in self.subviews {
            if view is T {return view as? T}
            guard let find = view.topViewOfType(T.self) else {
                continue
            }
            return find
        }
        return nil
    }
    
    static func parentViewController(_ responder: UIViewController.Type, ofView view: UIResponder) -> UIResponder? {
        guard let next = view.next else {return nil}
        guard next.isKind(of: responder) else {
            return parentViewController(responder, ofView: next)
        }
        return next
    }
    
    static func superViewOfType(_ responder: UIView.Type, ofView view: UIResponder) -> UIResponder? {
        guard let next = view.next else {return nil}
        guard next.isKind(of: responder) else {
            return superViewOfType(responder, ofView: next)
        }
        return next
    }
}
