//
//  UserTableViewModel.swift
//  Contacts
//
//  Created by TonnyLi on 22/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation
import CoreData
import SwiftInKotlinStyle

typealias ResultCompletion<T> = (Result<T, AppError>) -> Void

typealias Search = (segmentFilter: SegmentFilter, text: String)

enum LoadResourceStatus: Equatable {
    case `default`, loading, success, error(AppError)
}

class UserTableViewModel: NSObject {
    /* State */
    let hudStatus = ValueWrapper<LoadResourceStatus>(.default)
    let refreshStatus = ValueWrapper<LoadResourceStatus>(.default)
    let loadMoreStatus = ValueWrapper<LoadResourceStatus>(.default)
    let enableLoadMore = ValueWrapper<Bool>(false)
    
    let fetchedFromDB = ValueWrapper<[IndexPath]>([])
    
    
    /* Dependency */
    var currentPage: PageIndex = ApiConfig.firstPageIndex
    
    lazy var repository: UserRepository? = {
        UserRepositoryImpl(
            remoteDataSource: RemoteDataSourceImpl(),
            dataSyncEngine: DataSyncEngine(container: CoreDataStack.shared.persistentContainer)
        )
    }()
    
    var tableViewUpdater: FetchedResultsTableViewUpdater?
    
    init(_ tableViewUpdater: FetchedResultsTableViewUpdater) {
        self.tableViewUpdater = tableViewUpdater
    }
    
    /* Task methods */
    func initialData() {
        currentPage = ApiConfig.firstPageIndex
        
        _ = try? performFetch(currentPage)
        
        hudStatus.value = .loading
        repository?.fetchUsers(pageIndex: ApiConfig.firstPageIndex,
                               pageSize: ApiConfig.defaultPagingSize) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let list):
                self.hudStatus.value = .success
                self.enableLoadMore.value = list.count == ApiConfig.defaultPagingSize
            case .failure(let err):
                self.hudStatus.value = .error(err)
            }
        }
    }
    
    @objc func refresh(refresh: Any) {
        refreshStatus.value = .loading
        repository?.fetchUsers(pageIndex: ApiConfig.firstPageIndex,
                               pageSize: ApiConfig.defaultPagingSize) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                self.refreshStatus.value = .success
            case .failure(let err):
                self.refreshStatus.value = .error(err)
            }
        }
    }
    
    func loadMore() {
        loadMoreStatus.value = .loading
        
        _ = try? self.performFetch(currentPage + 1)
        
        repository?.fetchUsers(pageIndex: currentPage + 1,
                               pageSize: ApiConfig.defaultPagingSize) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let list):
                self.currentPage += 1

                self.loadMoreStatus.value = .success
                
                self.enableLoadMore.value = list.count == ApiConfig.defaultPagingSize
            case .failure(let err):
                self.loadMoreStatus.value = .error(err)
            }
        }
    }
    
    var fetchedObjects: [DBUser]? {
        fetchedResultsController.fetchedObjects
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<DBUser> = {
        let context = CoreDataStack.shared.mainContext
        
        let fetchRequest = NSFetchRequest<DBUser>(entityName: "User").also {
            $0.fetchLimit = ApiConfig.defaultPagingSize
            $0.sortDescriptors = [NSSortDescriptor(key: #keyPath(DBUser.uniqueId), ascending: true)]
            $0.fetchBatchSize = 15 //double size of cells count in screen
        }
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = tableViewUpdater
        
        return frc
    }()
    
    private func performFetch(_ pageIndex: PageIndex) throws -> Int {
        
        fetchedResultsController.fetchRequest.also {
            $0.fetchLimit = pageIndex * ApiConfig.defaultPagingSize
        }
        
        let oldCount = fetchedResultsController.fetchedObjects?.count ?? 0
        try fetchedResultsController.performFetch()
        let newCount = fetchedResultsController.fetchedObjects?.count ?? 0
        
        if newCount > oldCount {
            self.fetchedFromDB.value = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        }
        
        return newCount - oldCount
    }
    
    /* */
    private var search: Search = (.all, "")
    static let countInSearch = 50
}


extension UserTableViewModel {
    
    func searchWith(_ segmentFilter: SegmentFilter) {
        search.segmentFilter = segmentFilter
        
        doSearch(search)
    }
    
    func searchWith(_ text: String) {
        search.text = text
        
        doSearch(search)
    }
    
    private func doSearch(_ search: Search) {
        let (segmentFilter, text) = search
        if segmentFilter == .all && text.isEmpty { return }
        
        fetchedResultsController.fetchRequest.also {
            $0.fetchLimit = UserTableViewModel.countInSearch
            $0.predicate = NSPredicate(format: "firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@", text, text) && segmentFilter.predicate
        }
        
        do {
            try fetchedResultsController.performFetch()
            
            print("fetched: \(fetchedResultsController.fetchedObjects?.count ?? 0)")
        } catch {
            print(error.localizedDescription)
        }
    }
}
