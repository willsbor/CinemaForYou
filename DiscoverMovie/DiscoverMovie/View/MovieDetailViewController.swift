//
//  MovieDetailViewController.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/16.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import UIKit

protocol MovieDisplayDetail {
    var posterImage: URL { get }
    var backdropImage: URL { get }
    var title: String { get }
    var popularity: String { get }
    var synopsis: String { get }
    var genres: String { get }
    var language: String { get }
    var duration: String { get }
}

protocol MovieDetailControlling {
    func getFocusMovieDetail() -> MovieDisplayDetail
    func bookingFocusMove()
    func defocusMovie()
}

class MovieDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
