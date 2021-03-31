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

typealias IntResultCompletion = ResultCompletion<Int>

typealias DBEntityResultCompletion = ResultCompletion<[DBEntity]>

typealias Search = (segmentFilter: SegmentFilter, text: String)

enum LoadResourceStatus: Equatable {
    case `default`, loading, success, error(AppError)
}

class TableViewState {
    let hudStatus = LiveData<LoadResourceStatus>(.default)
    let refreshStatus = LiveData<LoadResourceStatus>(.default)
    let loadMoreStatus = LiveData<LoadResourceStatus>(.default)
    
    let enableLoadMore = LiveData<Bool>(false)
}

class UserTableViewModel: NSObject {
    /* State */
    let tableViewState = TableViewState()
    let fetchedFromDB = LiveData<[IndexPath]>([])
    
    /* Task methods */
    func initialData() {
        tableViewState.hudStatus.value = .loading
        
        loadData { [weak self] result in
            switch result {
            case .success(_):
                self?.tableViewState.hudStatus.value = .success
            case .failure(let err):
                self?.tableViewState.hudStatus.value = .error(err)
            }
        }
    }
    
    @objc func refresh(refresh: Any) {
        tableViewState.refreshStatus.value = .loading
        
        loadData { [weak self] result in
            switch result {
            case .success(_):
                self?.tableViewState.refreshStatus.value = .success
            case .failure(let err):
                self?.tableViewState.refreshStatus.value = .error(err)
            }
        }
    }
    
    func loadMore() {
        tableViewState.loadMoreStatus.value = .loading
        
        loadData(currentPage + 1) { [weak self] result in
            switch result {
            case .success(_):
                self?.tableViewState.loadMoreStatus.value = .success
            case .failure(let err):
                self?.tableViewState.loadMoreStatus.value = .error(err)
            }
        }
    }
    
    var currentPage: PageIndex = ApiConfig.firstPageIndex
    private var previousPagLastId: TypeOfId?
    
    /* Dependency */
    var tableViewUpdater: FetchedResultsTableViewUpdater?
    
    init(_ tableViewUpdater: FetchedResultsTableViewUpdater?) {
        self.tableViewUpdater = tableViewUpdater
    }
    
    var fetchedObjects: [DBUser]? {
        return fetchedResultsController.fetchedObjects
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<DBUser> = {
        let context = CoreDataStack.shared.mainContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: DBUser.entity().name ?? "User").also {
            $0.fetchLimit = ApiConfig.defaultPagingSize
            $0.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        }
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = tableViewUpdater
        
        return frc as! NSFetchedResultsController<DBUser>
    }()
    
    private func performFetch(_ pageIndex: PageIndex) throws -> Int {
        
        fetchedResultsController.fetchRequest.also {
            $0.fetchLimit = max(pageIndex * ApiConfig.defaultPagingSize, $0.fetchLimit)
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
    
    func loadData(_ pageIndex: PageIndex = ApiConfig.firstPageIndex, completion: @escaping DBIdsResultCompletion) {
        loadData(currentPage + 1, dbCompletion: { [weak self] result in
            
            self?.tableViewState.enableLoadMore.value = result.wrappedResult == ApiConfig.defaultPagingSize
            
        }) { [weak self] result in
            
            result.onSuccess {
                self?.tableViewState.enableLoadMore.value = $0.count == ApiConfig.defaultPagingSize
            }
            
            completion(result)
        }
    }

    func loadData(_ pageIndex: PageIndex = ApiConfig.firstPageIndex,
                  dbCompletion: @escaping IntResultCompletion,
                  apiCompletion: @escaping DBIdsResultCompletion) {
        
        /*
         load data from local db
         */
        let countFromLocalData: Int
        do {
            countFromLocalData = try performFetch(pageIndex)
        }catch {
            apiCompletion(.failure(.coredata(error.localizedDescription)))
            return
        }
        
        /*
         reload tableview if local data existed
         */
        dbCompletion(.success(countFromLocalData))
        
        /*
         load from api
         */
        let para: Parameters = ["page": "\(pageIndex)", "results": "\(ApiConfig.defaultPagingSize)", "seed": ApiConfig.defaultSeed]
        
        weak var weakSelf = self
        
        let previousPagLastId = self.previousPagLastId
        RemoteUserResponse.get(parameters: para) { apiResult in

            DispatchQueue.global().async {
                
                /*
                 sync remote data with local db
                 may need to update, insert or delete
                 */
                apiResult.syncWithDB(pageIndex, previousPagLastId) { idsResult in
                    
                    /*
                     cache lastId to delete local data in next page if necessory
                     */
                    apiResult.onSuccess { remoteUserResponse in
                        weakSelf?.previousPagLastId = remoteUserResponse.results.last?.fakeId
                    }
                    
                    DispatchQueue.main.async {
                        
                        if pageIndex > 1 {
                            
                            switch idsResult {
                            case .success(let array)
                                where array.count == ApiConfig.defaultPagingSize:
                                
                                weakSelf?.currentPage = pageIndex
                                
                            case .failure(let error)
                                where countFromLocalData == ApiConfig.defaultPagingSize && !error.isCoreDataError:
                                
                                /*
                                 enable infinite scrolling to load local data in next page
                                */
                                
                                weakSelf?.currentPage = pageIndex
                                
                            default: break
                            }
                        }
                        
                        apiCompletion(idsResult)
                    }
                }
            }
        }
    }
}

extension Result where Success == RemoteUserResponse, Failure == AppError {
    
    func syncWithDB(_ pageIndex: PageIndex, _ previousPagLastId: TypeOfId?, completion: @escaping DBIdsResultCompletion) {
        
        self.onSuccess { remoteUserResponse in
            
            //create unique id for items in api's result
            let remoteData = remoteUserResponse.unsafeBuildFakeIds(pageIndex)
            
            print("Remote ids:", remoteData.map { $0.fakeId ?? TypeOfId(0) })
            
            DBUser.keepConsistencyWith(previousPageLastId: previousPagLastId,
                                       remoteData: remoteData,
                                       condition: nil,
                                       completion: completion)
        }.onFailure {
            completion(.failure($0))
        }
    }
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
