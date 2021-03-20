//
//  SearchUserTableViewController.swift
//  Contacts
//
//  Created by TonnyLi on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import UIKit
import CoreData
import SVPullToRefresh
import SwiftInKotlinStyle

class SearchUserTableViewController: UITableViewController {
    
    private let filters: [SegmentFilter] = [.all, .byNationality("NZ"), .byNationality("US")]
        
    weak var nav: UINavigationController?
    
    lazy var viewModel = UserTableViewModel(FetchedResultsTableViewUpdater().also {
        $0.tableView = self.tableView
    })
    
    @IBAction func filterChanged(_ sender: UISegmentedControl) {
        viewModel.searchWith(filters[sender.selectedSegmentIndex])
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UserTableViewCell.dequeueReusableCellFor(tableView, indexPath)

        cell.data = viewModel.fetchedObjects?[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? UserTableViewCell
        
        let vc = UIStoryboard.main.viewController("ProfileTableViewController") as! ProfileTableViewController
        
        vc.thumbnailImage = cell?.avatarImgView.image
        vc.data = viewModel.fetchedObjects?[indexPath.row]
        
        nav?.pushViewController(vc, animated: true)
    }
    
    
    static func buildWith(_ navigationController: UINavigationController?) -> SearchUserTableViewController {
        let vc = UIStoryboard.main.viewController("SearchUserTableViewController") as! SearchUserTableViewController
        vc.nav = navigationController
        return vc
    }
}
