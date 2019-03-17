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
    +dataDelegate: MoviesChangeDelegate
    +currentMovies() -> [MovieResultType]
    +refreshMovies()
    +requestMoreMovies()
    +focusMovie()
}

enum MovieResultType {
  normal{MovieDisplayAbstract}
  hasMore
  lastOne
}

interface MovieDisplayAbstract {
  +posterImage
  +backdropImage
  +title
  +popularity
}

interface MoviesChangeDelegate {
  +begin()
  +movieDataDidChange(index, MovieDisplayAbstract)
  +end()
}

class MovieDetailViewController {
  +controller: MovieDetailControlling
}

interface MovieDetailControlling {
  +getFocusMovieDetail() -> MovieDisplayDetail
  +bookingFocusMove()
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
MoviesChangeDelegate ..> MovieResultType

DiscoverMovieTableViewController ..|> MoviesChangeDelegate

MovieDetailViewController *--> "1" MovieDetailControlling
MovieDetailControlling .right.> MovieDisplayDetail

```

### Business Rule

MainApp is the master of all. It owns the business rules. I design the neccessary interfaces. During a business flow, if MainApp can't support. it will ask another manager or helper by interface.

```puml
skinparam classAttributeIconSize 0

interface MovieDiscovering {
  +discoverMoviesNextState(User, DiscoverySortType, DiscoveryStatus?, handler)
}
interface MovieBooking {
  +bookMovie(User, MovieItem, handler)
}
interface User {
  +region
  +language
}

interface MovieItem {

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
  +movieDiscoverProvider: MovieDiscovering
  +movieBookProvider: MovieBooking
  +user: User
  +focusMovie: MovieItem?

  +discoverySort: DiscoverySortType
  +discoveryStatus: DiscoveryStatus?
  +discoverMovies: [MovieItem]
}

MainApp *--> "1" User
MainApp *--> "1" MovieDiscovering
MainApp *--> "1" MovieBooking
MainApp *--> "many" MovieItem
MainApp *--> "0..1" DiscoveryStatus
MainApp *--> "1" DiscoverySortType

class MovieDatabaseManager
class MovieData
class BookingMovieManager
class MainUser

MovieDatabaseManager .up.|> MovieDiscovering
BookingMovieManager .up.|> MovieBooking
MainUser .up.|> User
MovieDatabaseManager +-down- MovieData
MovieData .up.|> MovieItem

```

### the Relation of Interface Implementation

```puml
skinparam classAttributeIconSize 0

interface DiscoverMovieControlling
interface MovieDetailControlling
interface MovieItem
interface MovieDisplayDetail
interface MovieDisplayAbstract

MainApp ..|> DiscoverMovieControlling
MainApp ..|> MovieDetailControlling

MovieItem ..|> MovieDisplayDetail
MovieItem ..|> MovieDisplayAbstract
MovieData ..|> MovieItem

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
