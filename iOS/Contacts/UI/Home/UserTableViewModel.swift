//
//  UserTableViewModel.swift
//  Contacts
//
//  Created by TonnyLi on 22/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation
import UIKit
import CoreData

typealias IntResultCompletion = ResultCompletion<Int>

typealias DBEntityResultCompletion = ResultCompletion<[DBEntity]>

class UserTableViewModel: NSObject {
    
    private var searchFilter: Filter = .all
    private var searchTarget: String?

    private var previousPagLastId: TypeOfId?
    
    weak var tableView: UITableView?
    
    var currentPage: PageIndex = ApiConfig.firstPageIndex
    
    var fetchedObjects: [DBUser]? {
        return fetchedResultsController.fetchedObjects
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<DBUser> = {
        let context = CoreDataStack.shared.mainContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: DBUser.entity().name ?? "User").apply {
            $0.fetchLimit = ApiConfig.defaultPagingSize
            $0.sortDescriptors = [NSSortDescriptor(key: #keyPath(DBUser.id), ascending: true)]
        }
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        
        return frc as! NSFetchedResultsController<DBUser>
    }()
    
    func performFetch(_ pageIndex: PageIndex) throws -> Int {
        
        fetchedResultsController.fetchRequest.apply {
            $0.fetchLimit = max(pageIndex * ApiConfig.defaultPagingSize, $0.fetchLimit)
        }
        
        let oldCount = fetchedResultsController.fetchedObjects?.count ?? 0
        try fetchedResultsController.performFetch()
        let newCount = fetchedResultsController.fetchedObjects?.count ?? 0
        
        if newCount > oldCount {
            tableView?.beginUpdates()
            
            let indexPathes = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView?.insertRows(at: indexPathes, with: .bottom)
            
            tableView?.endUpdates()
        }
        
        return newCount - oldCount
    }
}

extension UserTableViewModel {
    
    func searchWith(_ filter: Filter) {
        guard let text = searchTarget else { return }
        
        searchFilter = filter
        
        search(filter, text)
    }
    
    func searchWith(_ text: String) {
        searchTarget = text
        
        search(searchFilter, text)
    }
    
    fileprivate func search(_ filter: Filter, _ text: String) {
        
        fetchedResultsController.fetchRequest.apply {
            $0.fetchLimit = 50
            $0.predicate = NSPredicate(format: "firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@", text, text) && filter.predicate
        }
        
        do {
            try fetchedResultsController.performFetch()
            tableView?.reloadData()
            
            print("fetched: \(fetchedResultsController.fetchedObjects?.count ?? 0)")
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension UserTableViewModel {
    
    func loadData(_ pageIndex: PageIndex = ApiConfig.firstPageIndex,
                  dbCompletion: @escaping IntResultCompletion,
                  apiCompletion: @escaping DBIdsResultCompletion) {
        
        /*
         load data from local db
         */
        let count: Int
        do {
            count = try performFetch(pageIndex)
        }catch {
            apiCompletion(.failure(.coredata(error.localizedDescription)))
            return
        }
        
        /*
         reload tableview if local data existed
         */
        dbCompletion(.success(count))
        
        /*
         load from api
         */
        let para: Parameters = ["page": "\(pageIndex)", "results": "\(ApiConfig.defaultPagingSize)", "seed": ApiConfig.defaultSeed]
        
        RemoteUserResponse.get(parameters: para) { [weak self] apiResult in

            DispatchQueue.global().async { [weak self] in
                
                /*
                 sync remote data with local db
                 may need to update, insert or delete
                 */
                apiResult.syncWithDB(pageIndex, self?.previousPagLastId) { [weak self] idsResult in
                    
                    /*
                     cache last id for delete local data in next page if necessory
                     */
                    apiResult.onSuccess { remoteUserResponse in
                        self?.previousPagLastId = remoteUserResponse.results.last?.fakeId
                    }
                    
                    DispatchQueue.main.async { [weak self] in
                        
                        if pageIndex > 1 {
                            idsResult.onSuccess {
                                if $0.count == ApiConfig.defaultPagingSize {
                                    self?.currentPage = pageIndex
                                }
                            }.onFailure {
                                if !$0.isCoreDataError && count == ApiConfig.defaultPagingSize {
                                    /*
                                     to enable infinite scrolling to load local data in next page
                                     */
                                    self?.currentPage = pageIndex
                                }
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
            
            print("Remote ids:", remoteData.map { $0.fakeId ?? -1 })
            
            DBUser.keepConsistencyWith(previousPageLastId: previousPagLastId,
                                       remoteData: remoteData,
                                       condition: nil,
                                       completion: completion)
        }.onFailure {
            completion(.failure($0))
        }
    }
}


extension UserTableViewModel: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controllerWillChangeContent")
        
        tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        print("didChange at indexPath")
        
        switch type {
        case .insert:
            tableView?.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView?.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView?.cellForRow(at: indexPath!)
        case .move:
            tableView?.deleteRows(at: [indexPath!], with: .fade)
            tableView?.insertRows(at: [newIndexPath!], with: .fade)
        default: break
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        print("didChange sectionInfo")
        
        switch type {
        case .insert:
            tableView?.insertSections(IndexSet(integer: sectionIndex) , with: .fade)
        case .delete:
            tableView?.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controllerDidChangeContent")
        
        tableView?.endUpdates()
    }
}
