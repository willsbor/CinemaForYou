//
//  DiscoverMovieTableViewController.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/16.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import UIKit

protocol MovieDisplayAbstract {
    var posterImage: URL? { get }
    var backdropImage: URL? { get }
    var title: String { get }
    var popularity: Double { get }
}

enum MovieResultType {
    case normal(MovieDisplayAbstract)
    case elseLeft
    case finial
}

enum MovieChangeType {
    case insert
    case replace
    case delete
}

protocol MoviesChangeDelegate {
    func begin()
    func movieDataDidChange(indexes: [Int], type: MovieChangeType)
    func end()
}

protocol DiscoverMovieControlling: class {
    var discoverDelegate: MoviesChangeDelegate? { get set }
    func currentMovies() -> [MovieResultType]
    func getMovie(by index: Int) -> MovieResultType
    func refreshMovies(_ completionHandler: @escaping () -> Void)
    func requestMoreMovies()
    func focusMovie(_ index: Int)
}

class DiscoverMovieTableViewController: UITableViewController {

    lazy var controller: DiscoverMovieControlling = MainApp.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controller.discoverDelegate = self
        
        self.title = "Discovery Movies"
        
        self.refreshControl = UIRefreshControl()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return controller.currentMovies().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let movieType = controller.getMovie(by: indexPath.row)
        
        switch movieType {
        case .normal(let info):
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath) as! MovieDisplayAbstractCell
            
            if let url = info.posterImage {
                cell.loadPosterImage(url)
            }
            if let url = info.backdropImage {
                cell.loadBackdropImage(url)
            }
            
            cell.titleLabel.text = info.title
            cell.popularityLabel.text = "\(info.popularity)"
            
            return cell
        case .elseLeft:
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath)
            return cell
        case .finial:
            let cell = tableView.dequeueReusableCell(withIdentifier: "finialCell", for: indexPath)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieType = controller.getMovie(by: indexPath.row)
        
        switch movieType {
        case .normal:
            controller.focusMovie(indexPath.row)
            performSegue(withIdentifier: "showMovieDetail", sender: nil)
            
        case .elseLeft, .finial:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let movieType = controller.getMovie(by: indexPath.row)
        
        if case .elseLeft = movieType {
            (cell as! MovieLoadingCell).indicatorView.startAnimating()
            print("controller.requestMoreMovies()")
            controller.requestMoreMovies()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let movieType = controller.getMovie(by: indexPath.row)
        switch movieType {
        case .normal:
            return 180.0
        case .elseLeft:
            return 44.0
        case .finial:
            return 44.0
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showMovieDetail":
            break
        default:
            assertionFailure("?? \(String(describing: segue.identifier))")
            break
        }
    }
    
    // MARK: - scrollView Delegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let refreshControl = refreshControl {
            if refreshControl.isRefreshing {
                controller.refreshMovies {
                    DispatchQueue.main.async {
                        self.refreshControl?.endRefreshing()
                        self.tableView.reloadSections([0], with: .automatic)
                    }
                }
            }
        }
    }
}

extension DiscoverMovieTableViewController: MoviesChangeDelegate {
    func begin() {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
        }
    }
    
    func movieDataDidChange(indexes: [Int], type: MovieChangeType) {
        DispatchQueue.main.async {
            switch type {
            case .insert:
                self.tableView.insertRows(at: indexes.map { IndexPath(row: $0, section: 0) }, with: .automatic)
            case .replace:
                self.tableView.reloadRows(at: indexes.map { IndexPath(row: $0, section: 0) }, with: .automatic)
            case .delete:
                self.tableView.deleteRows(at: indexes.map { IndexPath(row: $0, section: 0) }, with: .automatic)
            }
        }
        print("\(type): \(indexes)")
    }
    
    func end() {
        DispatchQueue.main.async {
            self.tableView.endUpdates()
        }
    }
}
