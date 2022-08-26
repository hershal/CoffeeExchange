//
//  CEEntryDetailTableController.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-27.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class CEEntryDetailTableController: NSObject, UITableViewDataSource, UITableViewDelegate, CETableItemDelegate {
    var viewModel: CEEntryDetailViewModel
    var delegate: CEEntryDetailTableControllerDelegate?
    var tableItems: [CETableItemBase]
    init(viewModel: CEEntryDetailViewModel) {
        self.viewModel = viewModel
        tableItems = [CETableItemBase]()
        super.init()
        tableItems = [CERemindMeTableItem(viewModel: viewModel, delegate: self),
                      CEMessageTableItem(viewModel: viewModel, delegate: self),
                      CECallTableItem(viewModel: viewModel, delegate: self)]
        tableItems = tableItems.filter({ (item) -> Bool in
            item.visible
        })
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "CEEntryDetailCell") {
            cell = dequeuedCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "CEEntryDetailCell")
        }
        cell.textLabel?.text = tableItems[indexPath.item].cellText
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItems.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableItems[indexPath.item].action()
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    // MARK: - CETableItemDelegate
    func tableItemPresentViewController(viewController: UIViewController) {
        delegate?.tableControllerPresentViewController(viewController: viewController)
    }
}

protocol CEEntryDetailTableControllerDelegate {
    func tableControllerPresentViewController(viewController: UIViewController)
}
