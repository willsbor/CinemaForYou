# CinemaForYou

## Class Diagram

### View / ViewController
prepare two ViewController
1. DiscoverMovieTableViewController
2. MovieDetailViewController

using interface to control the UI flow / Action

```puml
skinparam classAttributeIconSize 0

class DiscoverMovieTableViewController {
  +controller: DiscoverMovieControlling
}

interface DiscoverMovieControlling {
  +discoverDelegate: MoviesChangeDelegate?
  +currentMovies() -> [MovieResultType]
  +getMovie(by index: Int) -> MovieResultType
  +refreshMovies(_ completionHandler: @escaping () -> Void)
  +requestMoreMovies()
  +focusMovie(_ movieAbstract: MovieDisplayAbstract)
}

enum MovieResultType {
  normal{MovieDisplayAbstract}
  elseLeft
  finial
}

interface MovieDisplayAbstract {
  +posterImage: URL?
  +backdropImage: URL?
  +title: String
  +popularity: Double
}

enum MovieChangeType {
    insert
    replace
    delete
}

interface MoviesChangeDelegate {
  +begin()
  +movieDataDidChange(indexes: [Int], type: MovieChangeType)
  +end()
}

class MovieDetailViewController {
  +controller: MovieDetailControlling
}

interface MovieDetailControlling {
  +requestFocusMovieDetail(_ completionHandler: @escaping () -> Void)
  +getFocusMovieDetail() -> MovieDisplayDetail?
  +getBookingFocusMovieURL() -> URL
  +defocusMovie()
}

interface MovieDisplayDetail {
  +posterImage
  +backdropImage
  +title
  +popularity
  +synopsis
  +genres
  +language
  +duration
}

DiscoverMovieTableViewController .right.> MovieDetailViewController

DiscoverMovieTableViewController *--> "1" DiscoverMovieControlling
DiscoverMovieControlling .left.> MovieResultType
MovieResultType --> MovieDisplayAbstract
DiscoverMovieControlling --> "1" MoviesChangeDelegate : delegate
MoviesChangeDelegate ..> MovieChangeType

DiscoverMovieTableViewController ..|> MoviesChangeDelegate

MovieDetailViewController *--> "1" MovieDetailControlling
MovieDetailControlling .right.> MovieDisplayDetail

```

### Business Rule

MainApp is the master of all. It owns the business rules. I design the neccessary interfaces. During a business flow, if MainApp can't support. it will ask another manager or helper by interface.

```puml
skinparam classAttributeIconSize 0

interface MovieDatabase {
  +discoverMoviesNextState(User, DiscoverySortType, DiscoveryStatus?, handler)
  +detailMovie(_ movieItem: MovieItem, _ user: User, _ completionHandler: @escaping (MovieItem) -> Void)
}
interface MovieBooking {
  +bookMovie(_ user: User, _ movieItem: MovieItem) -> URL
}
interface User {
  +region
  +language
}

class MovieItem {
}

class DiscoveryStatus {
  +totalPages: Int
  +totalMovies: Int
  +currentPage: Int
}

enum DiscoverySortType {
  releaseDate
}

class MainApp << (S,#FF7700) Singleton >> {
  +movieDiscoverProvider: MovieDatabase
  +movieBookProvider: MovieBooking
  +user: User
  +focusMovie: MovieItem?

  +discoverySort: DiscoverySortType
  +discoveryStatus: DiscoveryStatus?
  +discoverMovies: [MovieItem]
}

MainApp *--> "1" User
MainApp *--> "1" MovieDatabase
MainApp *--> "1" MovieBooking
MainApp *--> "many" MovieItem
MainApp *--> "0..1" DiscoveryStatus
MainApp *--> "1" DiscoverySortType

class MovieDatabaseManager
class MovieData
class MovieDetailData
class BookingMovieManager
class MainUser

MovieDatabaseManager .up.|> MovieDatabase
BookingMovieManager .up.|> MovieBooking
MainUser .up.|> User
MovieDatabaseManager +-- MovieData
MovieDatabaseManager +-- MovieDetailData
MovieData <-- MovieItem
MovieDetailData <-- MovieItem

```

### the Relation of Interface Implementation

```puml
skinparam classAttributeIconSize 0

interface DiscoverMovieControlling
interface MovieDetailControlling
class MovieItem
interface MovieDisplayDetail
interface MovieDisplayAbstract

MainApp ..|> DiscoverMovieControlling
MainApp ..|> MovieDetailControlling

MovieItem ..|> MovieDisplayDetail
MovieItem ..|> MovieDisplayAbstract


```

### System Provider
in order to mock the system call in unit test, use system calls by SystemUtils interface

```puml
skinparam classAttributeIconSize 0

class SystemProvider << (S,#FF7700) Singleton >>

interface SystemUtils {
  +getRegion() -> String
  +getLanguage() -> String
  +currentDate() -> Date
  +dispatchAfter(_ milliseconds: Int, _ handler: @escaping () -> Void)
}

abstract SystemCapability {
  +systemUtils: SystemUtils
}

SystemProvider .up.|> SystemUtils
SystemCapability o-left-> "1" SystemUtils
```
