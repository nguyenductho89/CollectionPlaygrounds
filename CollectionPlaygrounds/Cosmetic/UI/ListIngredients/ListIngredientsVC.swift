//
//  ListIngredientsVC.swift
//  Cosmetic
//
//  Created by Nguyễn Đức Thọ on 8/27/21.
//

import UIKit
import CoreData

class ListIngredientsVC: UIViewController {
    var viewModel: ListIngredientsVMProtocol!
    var tableView: UITableView = {
        let tableView = UITableView(
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
extension ListIngredientsVC: UITableViewDelegate, UITableViewDatasource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
}
