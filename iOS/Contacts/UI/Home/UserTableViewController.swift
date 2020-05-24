//
//  UserTableViewController.swift
//  Contacts
//
//  Created by TonnyLi on 22/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import UIKit
import SVPullToRefresh
import CoreData

class UserTableViewController: UITableViewController {

    fileprivate lazy var viewModel: UserTableViewModel = {
        let viewModel = UserTableViewModel()
        viewModel.tableView = self.tableView
        return viewModel
    }()
    
    
    fileprivate lazy var mRefreshControl: UIRefreshControl = {
        let controler = UIRefreshControl()
        controler.addTarget(self, action: .refresh, for: .valueChanged)
        return controler
    }()
    
    
    fileprivate lazy var searchController: UISearchController = {
        let vc = UIStoryboard.main.viewController("SearchUserTableViewController") as! SearchUserTableViewController
        vc.nav = self.navigationController
        
        let controller = UISearchController(searchResultsController: vc)
        controller.searchResultsUpdater = self
        
        return controller
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        tableView.refreshControl = mRefreshControl
        setupInfiniteScrolling()
        
        initialData()
    }

    
    
    private func setupInfiniteScrolling() {
        
        tableView.addInfiniteScrolling { [unowned self] in
            
            self.loadData(self.viewModel.currentPage + 1) { _ in }
        }
        
        tableView.infiniteScrollingView.enabled = false
    }
    
    private func initialData() {
        
        let hud = navigationController?.view?.showHUD()
        
        loadData(ApiConfig.firstPageIndex) {
            hud?.hideWith($0.error)
        }
    }
    
    @objc func refresh(refresh: UIRefreshControl){
        
        loadData(ApiConfig.firstPageIndex) { [weak self] result in
            refresh.endRefreshing()
            
            result.error.ifSome {
                self?.navigationController?.view.showHUDMessage($0.humanReadableMessage)
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as! UserTableViewCell

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

extension UserTableViewController {
    
    fileprivate func loadData(_ pageIndex: PageIndex, _ completion: @escaping DBIdsResultCompletion) {
        
        let footerView = self.tableView.infiniteScrollingView
        
        viewModel.loadData(pageIndex, dbCompletion: { result in
            
            /*
            enable infinite scrolling if local has enough data
            */
            footerView?.enabled = result.unwrapResult == ApiConfig.defaultPagingSize

        }) { result in
            
            /*
            enable infinite scrolling
            */
            result.onSuccess {
                footerView?.enabled = $0.count == ApiConfig.defaultPagingSize
            }
            
            footerView?.stopAnimating()
            
            completion(result)
        }
    }
}

extension Selector {
    fileprivate static let refresh = #selector(UserTableViewController.refresh)
}

extension UserTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else { return }
            
        let vc = searchController.searchResultsController as? SearchUserTableViewController
        vc?.viewModel.searchWith(text)
    }
}
