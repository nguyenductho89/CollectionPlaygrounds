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
    let disposeBag = DisposeBag()
    lazy var scrollView: CustomTableview = {
        let v = CustomTableview()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .cyan
        v.delegate = self
        v.dataSource = self
        v.register(CustomCell.self, forCellReuseIdentifier: "Cell")
        v.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        v.register(SecondCustomCell.self, forCellReuseIdentifier: "SecondCustomCell")
        return v
    }()
    lazy var labelOne: UILabel = {
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
        disposeKeyboardHeight = self.rx.keyboardHeight
            .flatMap({ height -> Observable<KeyboardStatus> in
                let status: KeyboardStatus = height > 0 ? .show(withHeight: height) : .hide
                return Observable.just(status)
            })
            .debug("thond keybo", trimOutput: true)
            .withUnretained(self)
            .subscribe(onNext: { (owner, keyboardHeight) in
                switch keyboardHeight {
                    case .show(let height):
                        owner.offset = owner.scrollView.contentOffset
                        owner.scrollView.contentInset = UIEdgeInsets(top: 0,
                                                                     left: 0,
                                                                     bottom: height - owner.view.safeAreaInsets.bottom,
                                                                     right: 0)
                        let textfield = self.view.findTextfield().first(where: {$0.isEditing})
                        let frame = (UIView.superViewOfType(UIView.self, ofView: textfield!) as! UIView).convert(textfield!.superview!.frame, to: owner.scrollView)
                        owner.scrollView.scrollRectToVisible(frame, animated: false)
                    case .hide:
                        owner.scrollView.contentInset = .zero
                        owner.scrollView.setContentOffset(owner.offset, animated: true)
                }
            })
    }
    
    enum KeyboardStatus {
        case show(withHeight: CGFloat)
        case hide
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    var offset: CGPoint = .zero
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
