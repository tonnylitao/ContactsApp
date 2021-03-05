# ContactsApp

This demo shows how to develop mobile apps in different platforms (iOS, Android, Web). It's not about cross-platform. it's about taking fully advantage of best part of Swift, Kotlin and JS.

## Featuers

- api
- sync local data with remote data
- refresh, paging
- search local data
- offline

## iOS

- Protocol Oriented Programming
- Proper Extension
- CoreData

<p float="left">
 <img src="/Design/ios/home.png" width="250">
 <img src="/Design/ios/search.png" width="250">
 <img src="/Design/ios/detail.png" width="250">
</p>

## Android with Jetpack
- MVVM Architecture
- androidX
- NavigationUI
- Paging Library
- LiveData 
- Data-binding
- Room
- Coroutine
- other library: Material, Retrofit2, Glide, Shimmer, Timber, Flagkit

<p float="left">
 <img src="/Design/android/app_home.png" width="250">
 <img src="/Design/android/app_search.png" width="250">
 <img src="/Design/android/app_detail.png" width="250">
</p>

## React Native
- Typescript
- library: @react-navigation, react-native-svg-flagkit

<p float="left">
 <img src="/Design/reactnative/app_home_ios.png" width="250">
 <img src="/Design/reactnative/app_detail_ios.png" width="250">
  <img src="/Design/reactnative/app_home_android.png" width="250">
 <img src="/Design/reactnative/app_detail_android.png" width="250">
</p>

## What do you need to build a modern table in iOS and Android?
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

The new features(🆕) comes in either a new version of the support library called androidX (Android 9.0, API level 28, 2018), other kotlinx library (kotlinx-coroutines-android 2018), or new version of Android Studio (DataBinding needs Android Studio 3.4 2019). 

Which one seem more challenging to you?

## How to sync data (or keep consistency) between local and remote database when presenting table UI to users?

* There are two essential conditions for sync data properly. 
	1. UniqueId in both local database and remote sevice
	2. Same order in sqlite fetch and api (remote sql fetch)

In this demo app, the sync mechanism I used in iOS and android are slightly different.

### iOS sync mechanism

* If the api list is empty, it means there is no data in remote server, the local data need to be deleted with previous last id; 
* If it has only 1 item, it needs to be updated or created, and all the data after it need to be deleted.
* otherwise, to update, insert, or delete that list, and it may need to delete when the page is not fully loaded.

```swift
static func syncToDBWith(previousPageLastId: Int?, apiData: [User] {
    
    let count = apiData.count
    if count == 0 {

        deleteAllAfter(id: previousPageLastId)
        
    }else if count == 1 {
        deleteAllAfter(id: apiData.last!.id)
        
        updateOrInsert(apiData.last)
    }else {
        if count < pagingSize {
            deleteAllAfter(id: apiData.last!.id)
        }
	
	deleteOrUpdateOrInsert(apiData)
    }
}
```

Programming in CoreData, there are some good and popular practices:

* when upsert a list, find in batch rather than find them one by one.
* perform all I/O operation in background thread, merge updates into UI thread
* delete first, update later. to get avoid of unnecessory query job

iOS supports NSFetchedResultsController which can update table view automatically when data is inserted, updated or deleted. Forget about the child-main-root 3 layer contexts which is main stream in years ago, iOS 10 simplifies the contexts and thread operation, Thanks to CoreData framework, iOS developer has fewer things to do.

### Android sync mechanism
To simplify the task, this Android project does not implement fetch-update or fetch-insert like iOS. The api items are upserted by hitting database which is polished by Room/Sqlite conflict strategy. Thanks to Room and Coroutine, it's only a few lines of code.

```kotlin
@Insert(onConflict = OnConflictStrategy.IGNORE)
suspend fun insertIfNotExisted(entities: List<T>): List<Long>

@Transaction
suspend fun upsert(entities: List<User>) {
    val rowIDs = insertIfNotExisted(entities)
    val toUpdate = rowIDs.mapIndexedNotNull { index, rowID ->
        if (rowID == -1L) entities[index] else null
    }
    toUpdate.forEach { update(it) }
}
```

```kotlin
suspend fun syncToDBWith(apiData: List<ApiUser>, offset: Int) {

    val count = apiData.size
    db.withTransaction {
        if (count == 0) {
		dao.deleteAllOffset(offset) //hitting db
        }else {
        	dao.upsert(apiData) //hitting db
        	
		if (count < pagingSize) {
			dao.deleteAllAfter(apiData.last().id)
		}
        }
    }
}
```

## Data-driven UI
A mechanism of updateing table view after data being inserted, updated or deleted. Data flows from api to UI:

``` 
http
		decode/deserialize  -> api Model 
		mapping		-> Entity Model 
		C_UD		-> db 
		query		-> UI model in container 
		update		-> UI
```

| | iOS with CoreData | Android with Room | Tips |
| ---- | ---- | ---- | ---- |
|http|Session/Alamofire| Retrofit2 |
|api Model| struct implement Decodable protocol | data class with deserialization | Optional or not, it's a question
| Entity Model | CoreData's NSManagedObject | Room's Entity |
| Create<br>Updata<br>Delete | CoreData's background context | Coroutine, Room's Dao | Find-in-Batch<br>(Room) use sqlite conflict strategy
| Query | NSFetchedResultsController, NSPredicate | DataSource.Factory, DataSource<br>(ItemKeyedDataSource,<br>PageKeyedDataSource,<br>PositionalDataSource) | Query columns only necessory
| UI Model | CoreData's NSManagedObject | Room's Entity or<br> data class embedded Room's Entity  | Recommend to embed a slim Entity
| Data Container | CoreData's view context | PagedList, LiveData | PagedList is immutable, a new PagedList/DataSource pair need to create when data change
| To Update UI | NSFetchedResultsControllerDelegate | Adapter | Don't Repeat Delegates and Adapters
| Controller | UITableViewController | Fragment, ViewModel |
| UI | UITableView | RecyclerView |

The newest Paging Library supports three kinds of DataSource. It depends on the web api (index paging, item paging, load forward, load backward). You have ItemKeyedDataSource, PageKeyedDataSource and PositionalDataSource to choose. Chill up, give youself a couple days to decide which you need to use. And if you are not satisfied with them, alternatively you can implement your own DataSource.

## Which DataSource should I use in Android Paging Library?
| If API supports | DataSource | callback to serve data
| ---- | ---- | ---- |
| pageAfter:id| Dao's DataSource.Factory| PagedList.BoundaryCallback
| pageIndex, pageSize | PageKeyedDataSource| LoadInitialCallback<br>LoadCallback

* First solution: the data feeding UI directly domes from DB, and the UI will be updated automatically after DB operation (CUD). This is priority choice.
* Second solution: LoadInitialCallback and LoadCallback cannot call twice, it means that returning cached data first and api data later is impossible. The datasouce has to be invalidated and new PagedList/DataSouce pair need to be created. There are two ways to fetch-update ui. 

	The first way: 
	* 1. cached data fetched
	* 2. update UI with cache
	* 3. web api called
	* 4. when update existed, invaldate datasouce, go to first step, but get avoid of web api calling again, otherwise it may loop forever.
	
	The second way:
	
	* 1. web api called
	* 2. update UI with remote data
	* 3. cache data for offline only

In this Android demo, because the api only support index+size paging, so I used PageKeyedDataSource with the second fetch-upate way.

## A summary of this app about mobile development. (on going)

- [Good practices in iOS development](/swift.md)
- [Good practices in Android development](/kotlin.md)
- [Comparison between Swift and Kotlin](/swift_vs_kotlin.md)
- [What I've learned from Kotlin as iOS developer](/kotlin_for_ios.md)
- What I've learned from Swift as Android developer
- [Android ViewModel 2020: create different viewModels in one place](https://medium.com/@tonny/android-viewmodel-with-variable-arguments-eb6cb028335d)
- [Android ReyclerView 2020: create different Adapters in one place](https://medium.com/@tonny/recyclerview-2020-when-recyclerview-meets-data-binding-616ca5c2147d)

## TODO
- iOS SwiftUI with Combine framework
- Android Compose
- React/Redux
- Next.js
- Unit Testing
