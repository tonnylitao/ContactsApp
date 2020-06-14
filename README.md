# Contacts mobile app

This demo shows how to develop mobile apps in different platforms (iOS, Android, Web). It's not about cross-platform. it's about taking fully advantage of best part of Swift, Kotlin and JS.

### iOS

<p float="left">
 <img src="/Design/ios/home.png" width="250">
 <img src="/Design/ios/search.png" width="250">
 <img src="/Design/ios/detail.png" width="250">
</p>

- Protocol Oriented Programming
- Proper Extension
- CoreData

### Android with Jetpack

<p float="left">
 <img src="/Design/android/app_home.png" width="250">
 <img src="/Design/android/app_search.png" width="250">
 <img src="/Design/android/app_detail.png" width="250">
</p>

- MVVM Architecture
- androidX
- NavigationUI
- Paging Library
- LiveData 
- Data-binding
- Room
- Coroutine
- other library: Material, Retrofit2, Glide, Shimmer, Timber, Flagkit

### What do you need to build a modern table in iOS and Android?
The following graphic lists the basic MVC knowledge of table or list UI in iOS and Android, which is supported by platform's framework. For iOS, there is no any big change in both architecture and api since iOS 2.0 (12 yrs). 

However, Android brings a huge change, and the change is constantly comming with next releases.

| | iOS | Android |
---- | ---- | ---- |
Controller | UITableViewController | Activiy<br> AppCompatActivity  🆕<br> ViewModel 🆕 or<br>AndroidViewModel 🆕
UI components | UITableView<br>UITableViewCell | Fragment 🆕<br>ListView / RecyclerView 🆕<br>RecyclerView.ViewHolder 🆕<br>Lifecycle and LifecycleOwner 🆕<br>NavigationUI 🆕
Layout | .xib or .storyboard (iOS 5)<br>AutoLayout (iOS 6) | .xml<br>LinearLayout<br>ConstraintLayout 🆕
View access | viewWithTag or<br>IBOutlet | findViewById or<br>synthetic 🆕<br>View Binding 🆕
Delegate<br>DataSource | UITableViewDelegate<br>UITableViewDataSource | PagedListAdapter 🆕<br>AsyncPagedListDiffer 🆕<br>Paging library 🆕<br>DataSource.Factory 🆕<br>(ItemKeyedDataSource 🆕,<br>PageKeyedDataSource 🆕,<br>PositionalDataSource 🆕) 
Data Binding | | Data Binding 🆕<br>LiveData 🆕
Model-to-DB | CoreData (iOS 3) | Room 🆕
Concurrency | GCD (iOS 8) | Coroutine 🆕

The new features(🆕) comes in either a new version of the support library called androidX (Android 9.0, API level 28, 2018), other kotlinx library (kotlinx-coroutines-android 2018), or new version of Android Studio (DataBinding needs Android Studio 3.4 2019). Which one seem more challenging to you?

### How to sync data (or keep consistency) between local and remote database when presenting table UI to users?

* There are two essential conditions for sync data properly. 
	1. UniqueId in both local database and remote sevice
	2. Same order in sqlite fetch and api (remote sql fetch)

In this demo app, the sync mechanism I used in iOS and android slightly different.

##### iOS sync mechanism

* If the api list is empty, it means there is no data in remote server, the local data need to be deleted with previous last id; 
* If it has only 1 item, it needs to be updated or created, and all the data after it need to be deleted.
* otherwise, to update, insert, or delete that list, and it may need to delete when the page is not fully loaded.

```swift
static func syncToDBWith(previousPageLastId: Int?, apiData: [User] {
    
    let count = apiData.count
    if count == 0 {

        deleteAllAfter(id: previousPageLastId)
        
    }else if count == 1 {
        deleteAllAfter(id: apiData.last.id)
        
        updateOrInsert(apiData.last)
    }else {
        deleteOrUpdateOrInsert(apiData)
        
        if count < pagingSize {
            deleteAllAfter(id: apiData.last?.id)
        }
    }
}
```

Programming in CoreData, there are some good and popular practices:

* when upsert a list, find in batch rather than find them one by one.
* perform all I/O operation in background thread, merge updates into UI thread
* delete first, update later. to get avoid of unnecessory query job

iOS supports NSFetchedResultsController which can update table view automatically when data is inserted, updated or deleted. Forget about the child-main-root 3 contexts which is main stream in years ago, iOS 10 simplifies the contexts and thread operation, Thanks to CoreData framework, iOS developer has fewer things to do. But in Android, it goes wild.

##### Android sync mechanism
The newest Paging Library supports three kinds of DataSource. It depends on the user interaction of recycler view and the web api. You have ItemKeyedDataSource, PageKeyedDataSource and PositionalDataSource to choose. Chill up, give youself a couple days to decide which you need to use. And if you are not satisfied about them, alternatively you can implement your own DataSource.


### Data-driven UI. (on going)
A mechanism of updateing list view after data being inserted, updated or deleted. Data flows from api to UI:
``` 
Api decode/deserialize  -> Api model 
    mapping		-> Entity model 
    save		-> db 
    query		-> UI model 
    update		-> UI
```

| | iOS, UITableView | Android, RecyclerView |
| ---- | ---- | ---- |
Model creation | NSManagedObjectContext.save()<br>(backgroundContext,viewContext) | RoomDao.upsert
Update UI(1) | NSFetchedResultsControllerDelegate | DataSource.Factory<br>LiveData<br>PagedListAdapter<br>PagedList<br>BoundaryCallback
Update UI(2) | | DataSource.Factory<br>LiveData<br>PagedListAdapter<br>PagedList<br>PageKeyedDataSource

* Android

The PagedList tries to get the first chunk of data from the DataSource. When the DataSource is empty, the BoundaryCallback requests from the network and inserts into db.

 <img src="/Design/android/paging_1.gif">
 
After the inserting, a new LiveData\<PagedList> is created automatically and passed to ViewModel and PagedListAdapter to update UI.
 
 <img src="/Design/android/paging_2.gif">
 
When load more, DataSource queries next page from db, and BoundaryCallback requests next page from the network and inserts/updates/deletes them into db. The UI then gets re-populated with the newly-loaded data.

 <img src="/Design/android/paging_3.gif">

### A summary of this app about mobile development. (on going)

- [Good practices in iOS development](/swift.md)
- [Good practices in Android development](/kotlin.md)
- [What I've learned from Kotlin as iOS developer](/kotlin_for_ios.md)
- [Comparison between Swift and Kotlin](/swift_vs_kotlin.md)

### TODO
- JS bridge between web and native (ios and android)
- Reactive in Combine framework
- Android Compose
- React SAP
- Next.js
- Redux & Redux-saga