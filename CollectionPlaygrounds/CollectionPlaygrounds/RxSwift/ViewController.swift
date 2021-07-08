//
//  ViewController.swift
//  s
//
//  Created by Nguyen Duc Tho on 7/5/21.
//

import UIKit
import RxCocoa
import RxSwift

class CustomTableview: UITableView {
    override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        super.scrollRectToVisible(rect, animated: animated)
        print("thond: scrollRectToVisible \(rect)")
    }
    
    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        super.setContentOffset(contentOffset, animated: animated)
        print("thond: setContentOffset \(contentOffset)")
    }
}

class ViewController: UIViewController {
    lazy var scrollView: CustomTableview = {
        let v = CustomTableview()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .cyan
        return v
    }()
    let labelOne: UILabel = {
        let label = UILabel()
        label.text = "Scroll Top"
        label.backgroundColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let labelTwo: UILabel = {
        let label = UILabel()
        label.text = "Scroll Bottom"
        label.backgroundColor = .green
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var disposeKeyboardHeight: RxSwift.Disposable?
    var autoScroll: CGFloat = 0.0
    var isShowKeyboard = false
    private var needToMoveUpTable: Bool = false
    private var needToRecallOffset: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(scrollView)
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        scrollView.delegate = self
        scrollView.dataSource = self
        scrollView.register(CustomCell.self, forCellReuseIdentifier: "Cell")
        scrollView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        scrollView.register(SecondCustomCell.self, forCellReuseIdentifier: "SecondCustomCell")
        
        
        // add labelOne to the scroll view
        scrollView.addSubview(labelOne)
        
        // constrain labelOne to left & top with 16-pts padding
        // this also defines the left & top of the scroll content
        labelOne.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.0).isActive = true
        labelOne.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16.0).isActive = true
        
        // add labelTwo to the scroll view
        // scrollView.addSubview(labelTwo)
        
        // constrain labelTwo at 400-pts from the left
        //        labelTwo.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
        //
        //        // constrain labelTwo at 1000-pts from the top
        //        labelTwo.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 1500).isActive = true
        //
        //        // constrain labelTwo to right & bottom with 16-pts padding
        //        labelTwo.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16.0).isActive = true
        //        labelTwo.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16.0).isActive = true
        
        //scrollView.addSubview(textfield)
        //        textfield.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 10).isActive = true
        //        textfield.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 10).isActive = true
        //        textfield.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).isActive = true
        //        textfield.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        //        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        //                disposeKeyboardHeight = self.rx.keyboardHeight.withUnretained(self)
        //            .subscribe(onNext: { (owner, keyboardHeight) in
        //                guard keyboardHeight > 0 else {
        //                    guard self.autoScroll > 0 else {return}
        //                    let currentContentOffset = owner.scrollView.contentOffset
        ////                    self.scrollView.setContentOffset(CGPoint(x: currentContentOffset.x, y: currentContentOffset.y + self.autoScroll), animated: false)
        //                    self.scrollView.contentInset = .zero
        //                    return
        //                }
        //                guard let scrollView = owner.view.topViewOfType(UIScrollView.self) else {return}
        //                let bottomTextfield: UITextField? = scrollView
        //                    .findTextfield()
        //                    .filter {$0.isEditing}
        //                    .first
        //                let position = bottomTextfield?.superview?.convert((bottomTextfield?.frame)!, to: self.scrollView)
        //                let yBottomTextfield = (position?.origin.y ?? 0) + (position?.size.height ?? 0) - self.scrollView.contentOffset.y
        //                print("thond: y \(yBottomTextfield)")
        //                let distance = yBottomTextfield + keyboardHeight - scrollView.frame.size.height
        //                print("thond: height \(scrollView.frame.size.height)")
        //                print("thond: distance \(distance)")
        //                guard distance > 0 else {return}
        //                owner.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: distance, right: 0)
        //                let currentContentOffset = owner.scrollView.contentOffset
        //                self.autoScroll = distance
        ////                owner.scrollView.setContentOffset(CGPoint(x: currentContentOffset.x, y: currentContentOffset.y - distance), animated: false)
        //            }, onDisposed: {
        //                NotificationCenter.default.removeObserver(self)
        //            })
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 336-83, right: 0)
        //scrollView.contentSize.height = scrollView.contentSize.height + 400
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    var offset: CGPoint?
    var isShown = false
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
            scrollView.setContentOffset(offset!, animated: true)
            isShown = false
        } else {
            guard !isShown else {return}
            isShown = true
            offset = scrollView.contentOffset
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
            let textfield = self.view.findTextfield().first(where: {$0.isEditing})
            //let frame = textfield?.superview?.superview?.convert(textfield!.superview!.frame, to: self.scrollView)
            let frame = (UIView.superViewOfType(UIView.self, ofView: textfield!) as! UIView).convert(textfield!.superview!.frame, to: self.scrollView)
            scrollView.scrollRectToVisible(frame, animated: false)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
}
class CustomScrollView: UIScrollView {
    override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        super.scrollRectToVisible(rect, animated: animated)
    }
}
class CustomCell: UITableViewCell {
    lazy var scrollView: CustomScrollView = {
        let v = CustomScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentSize.width = 1500
        v.backgroundColor = .green
        return v
    }()
    lazy var textfield: UITextField = {
        let textfield = UITextField(frame: .zero)
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.backgroundColor = .white
        return textfield
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(scrollView)
        scrollView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 5).isActive = true
        scrollView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        scrollView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 5).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        textfield.backgroundColor = .lightGray
        scrollView.addSubview(textfield)
        textfield.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 10).isActive = true
        textfield.widthAnchor.constraint(equalToConstant: 300).isActive = true
        textfield.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 5).isActive = true
        textfield.heightAnchor.constraint(equalToConstant: 30).isActive = true
        scrollView.resignFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SecondCustomCell: UITableViewCell {
    
    lazy var textfield: UITextField = {
        let textfield = UITextField(frame: .zero)
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.backgroundColor = .white
        return textfield
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //        self.contentView.addSubview(textfield)
        //        textfield.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        //        textfield.widthAnchor.constraint(equalToConstant: 300).isActive = true
        //        textfield.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        //        textfield.heightAnchor.constraint(equalToConstant: 30).isActive = true
        let view = UIView(frame: self.contentView.frame)
        view.backgroundColor = .yellow
        self.contentView.addSubview(view)
        view.addSubview(textfield)
        textfield.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        textfield.widthAnchor.constraint(equalToConstant: 300).isActive = true
        textfield.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        textfield.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 13 ? 100 : 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 14 {
            let cell: CustomCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
            cell.selectionStyle = .none
            return cell
        } else if indexPath.row == 12 {
            let cell: SecondCustomCell = tableView.dequeueReusableCell(withIdentifier: "SecondCustomCell", for: indexPath) as! SecondCustomCell
            cell.backgroundColor = .red
            cell.selectionStyle = .none
            return cell
        } else {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            cell.selectionStyle = .none
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 14 {
            self.view.endEditing(true)
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let bottomTextfield: UITextField? = scrollView
            .findTextfield()
            .filter {$0.isEditing}
            .first
        let cell = scrollView.cellForRow(at: IndexPath(row: 13, section: 0))
        let position = bottomTextfield?.superview?.convert((bottomTextfield?.frame.origin)!, to: self.view.window)
        print(position)
    }
}
