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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let movie = controller.getFocusMovieDetail()
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PosterCell", for: indexPath) as! MovieDetailPosterCell
            
            #warning("TODO: image async load / cache")
            if let url = movie.posterImage {
                cell.posterImageView.image = UIImage(data: try! Data(contentsOf: url))
            }
            
            return cell
        case 1...6:
            let (title, content) = movie.getTitleContent(indexPath.row)
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath) as! MovieDetailContentCell
            
            cell.titleLabel.text = title
            cell.contentLabel.text = content
            
            return cell
            
        default:
            preconditionFailure("undefined")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MovieDisplayDetail {
    fileprivate func getTitleContent(_ index: Int) -> (String, String) {
        switch index {
        case 1:
            return ("Title", title)
        case 2:
            return ("Popularity", popularity)
        case 3:
            return ("Synopsis", synopsis)
        case 4:
            return ("Genres", genres)
        case 5:
            return ("Language", language)
        case 6:
            return ("Duration", duration)
        default:
            preconditionFailure()
        }
    }
}
