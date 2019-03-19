//
//  MovieDetailContentTableViewController.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/17.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import UIKit

class MovieDetailContentTableViewController: UITableViewController {

    var controller: MovieDetailControlling! = nil
    var scrollViewDidScrollHandler: ((_ contentOffset: CGPoint) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let movie = controller.getFocusMovieDetail()
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PosterCell", for: indexPath) as! MovieDetailPosterCell
            
            if let url = movie?.posterImage {
                cell.loadPosterImage(url)
            }
            
            return cell
        case 1...7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath) as! MovieDetailContentCell
            
            if let (title, content) = movie?.getTitleContent(indexPath.row) {
                cell.titleLabel.text = title
                cell.contentLabel.text = content
            }
            
            return cell
            
        default:
            preconditionFailure("undefined")
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 250.0
        default:
            return 44.0
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScrollHandler?(scrollView.contentOffset)
    }
}

extension MovieDisplayDetail {
    fileprivate func getTitleContent(_ index: Int) -> (String, String) {
        switch index {
        case 1:
            return ("Title", title)
        case 2:
            return ("Popularity", "\(popularity)")
        case 3:
            return ("Synopsis", synopsis)
        case 4:
            return ("Genres", genres)
        case 5:
            return ("Language", language)
        case 6:
            return ("Duration", duration)
        case 7:
            return ("Release Date", releaseDate)
        default:
            preconditionFailure()
        }
    }
}
