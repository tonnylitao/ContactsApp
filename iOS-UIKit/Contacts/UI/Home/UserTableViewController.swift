//
//  UserTableViewController.swift
//  Contacts
//
//  Created by TonnyLi on 22/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import UIKit
import CoreData
import SVPullToRefresh
import SwiftInKotlinStyle
import MBProgressHUD

class UserTableViewController: UITableViewController {
    
    private lazy var viewModel = UserTableViewModel(FetchedResultsTableViewUpdater().also {
        $0.tableView = self.tableView
    })
    
    private lazy var searchController = UISearchController(searchResultsController: SearchUserTableViewController.buildWith(self.navigationController)).also {
        $0.searchResultsUpdater = self
    }
    
    var observer: NSKeyValueObservation!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        tableView.refreshControl = UIRefreshControl().also {
            $0.addTarget(self.viewModel, action: #selector(UserTableViewModel.refresh), for: .valueChanged)
        }
        
        tableView.addInfiniteScrolling(actionHandler: viewModel.loadMore)
        tableView.infiniteScrollingView.enabled = false
        tableView.prefetchDataSource = self
        
        bind()
        
        viewModel.initialData()
    }
    
    private func bind() {
        var hud: MBProgressHUD?
        viewModel.hudStatus.observe { [weak self] value in
            guard let self = self else {
                hud?.hide(animated: false)
                return
            }
            
            switch value {
            case .default:
                break
            case .loading:
                hud?.hide(animated: false)
                hud = self.navigationController?.view?.showHUD()
            case .success:
                self.tableView.reloadData()
                hud?.hide(animated: false)
            case .error(let err):
                hud?.hideWith(err)
            }
        }
        
        viewModel.refreshStatus.observe { [weak self] value in
            guard let self = self else { return }
            
            switch value {
            case .default, .loading:
                break
            case .success:
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            case .error(let err):
                self.refreshControl?.endRefreshing()
                self.view.showHUDMessage(err.humanReadableMessage)
            }
        }
        
        viewModel.loadMoreStatus.observe { [weak self] value in
            guard let self = self else { return }
            
            switch value {
            case .default, .loading:
                break
            case .success:
                self.tableView.infiniteScrollingView.stopAnimating()
            case .error(let err):
                self.tableView.infiniteScrollingView.stopAnimating()
                self.view.showHUDMessage(err.humanReadableMessage)
            }
        }
        
        viewModel.enableLoadMore.observe { [weak self] enableLoadMore in
            guard let self = self else { return }
            
            self.tableView.infiniteScrollingView?.enabled = enableLoadMore
        }
        
        viewModel.fetchedFromDB.observe { [weak self] indexPathes in
            guard let self = self else { return }
            
            self.tableView?.beginUpdates()
            self.tableView?.insertRows(at: indexPathes, with: .bottom)
            self.tableView?.endUpdates()
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        
        let vc = segue.destination as? ProfileTableViewController
        vc?.thumbnailImage = (cell as? UserTableViewCell)?.avatarImgView.image
        vc?.data = viewModel.fetchedObjects?[indexPath.row]
    }
}

extension UserTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else { return }
        
        let vc = searchController.searchResultsController as? SearchUserTableViewController
        vc?.viewModel.searchWith(text)
        tableView.reloadData()
    }
}

extension UserTableViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let fetchRequest: NSFetchRequest<DBUser> = DBUser.fetchRequest().also {
            $0.returnsObjectsAsFaults = false
            
            let items = indexPaths.map { self.viewModel.fetchedResultsController.object(at: $0) }
            $0.predicate = NSPredicate(format: "SELF IN %@", items)
        }
        
        let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest)
        do {
            try self.viewModel.fetchedResultsController.managedObjectContext.execute(asyncFetchRequest)
        } catch { }
    }
}
