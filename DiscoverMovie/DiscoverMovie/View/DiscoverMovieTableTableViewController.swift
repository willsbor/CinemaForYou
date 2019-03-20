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
    var releaseDate: String { get }
}



protocol DiscoverMovieControlling: class {
    var isFinal: Bool { get }
    func currentMovies() -> [MovieDisplayAbstract]
    func getMovie(by index: Int) -> MovieDisplayAbstract?
    func refreshMovies(_ completionHandler: @escaping () -> Void)
    func requestMoreMovies(_ completionHandler: @escaping (_ originalItemsCount: Int, _ appendedMovieItemsCount: Int) -> Void)
    func focusMovie(_ index: Int)
}

extension DiscoverMovieControlling {
    func currentMovieCellTypes() -> [DiscoverMovieTableViewController.CellType] {
        var results: [DiscoverMovieTableViewController.CellType] = currentMovies().map { .normal($0) }
        results.append(tailCellType())
        return results
    }
    
    func getMovieCellType(by index: Int) -> DiscoverMovieTableViewController.CellType {
        if let movie = getMovie(by: index) {
            return .normal(movie)
        } else {
            return tailCellType()
        }
    }
    
    private func tailCellType() -> DiscoverMovieTableViewController.CellType {
        if isFinal {
            return .final
        } else {
            return .elseLeft
        }
    }
}

class DiscoverMovieTableViewController: UITableViewController {

    enum CellType {
        case normal(MovieDisplayAbstract)
        case elseLeft
        case final
    }
    
    lazy var controller: DiscoverMovieControlling = MainApp.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Discovery Movies"
        
        self.refreshControl = UIRefreshControl()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.currentMovieCellTypes().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let movieType = controller.getMovieCellType(by: indexPath.row)
        
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
            cell.releaseDateLabel.text = info.releaseDate
            
            return cell
        case .elseLeft:
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath)
            return cell
        case .final:
            let cell = tableView.dequeueReusableCell(withIdentifier: "finalCell", for: indexPath)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieType = controller.getMovieCellType(by: indexPath.row)
        
        switch movieType {
        case .normal:
            controller.focusMovie(indexPath.row)
            performSegue(withIdentifier: "showMovieDetail", sender: nil)
            
        case .elseLeft, .final:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let movieType = controller.getMovieCellType(by: indexPath.row)
        
        if case .elseLeft = movieType {
            (cell as! MovieLoadingCell).indicatorView.startAnimating()
            print("controller.requestMoreMovies()")
            controller.requestMoreMovies { (originalItemsCount, appendedItemsCount) in
                DispatchQueue.main.async {
                    self.displayAppendedItems(originalItemsCount, appendedItemsCount)
                }
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let movieType = controller.getMovieCellType(by: indexPath.row)
        switch movieType {
        case .normal:
            return 180.0
        case .elseLeft:
            return 44.0
        case .final:
            return 44.0
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showMovieDetail":
            let vc = (segue.destination as! MovieDetailViewController)
            vc.controller.requestFocusMovieDetail { [weak vc] in
                DispatchQueue.main.async {
                    vc?.reloadContent()
                }
            }
            
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
                controller.refreshMovies { [weak self] in
                    DispatchQueue.main.async {
                        self?.refreshControl?.endRefreshing()
                        self?.tableView.reloadSections([0], with: .automatic)
                    }
                }
            }
        }
    }
    
    // MARK: -
    
    private func displayAppendedItems(_ originalItemsCount: Int, _ appendedMovieItemsCount: Int) {
        tableView.beginUpdates()
        
        let tailCellIndex = originalItemsCount
        
        tableView.reloadRows(at: [IndexPath(row: tailCellIndex, section: 0)], with: .automatic)
        
        if appendedMovieItemsCount > 0 {
            let insertItems = [Int](1...appendedMovieItemsCount).map { IndexPath(row: $0 + tailCellIndex, section: 0) }
            tableView.insertRows(at: insertItems, with: .automatic)
        }
        
        tableView.endUpdates()
    }
}
