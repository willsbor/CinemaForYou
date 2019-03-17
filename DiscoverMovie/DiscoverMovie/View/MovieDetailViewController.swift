//
//  MovieDetailViewController.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/16.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import UIKit

protocol MovieDisplayDetail {
    var posterImage: URL? { get }
    var backdropImage: URL? { get }
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

    var controller: MovieDetailControlling = MockController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Book me", style: .plain, target: self, action: #selector(clickBookMovie))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            controller.defocusMovie()
        }
    }
    
    @objc func clickBookMovie() {
        controller.bookingFocusMove()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ContentTable":
            (segue.destination as! MovieDetailContentTableViewController).controller = controller

        default:
            assertionFailure("?? \(String(describing: segue.identifier))")
            break
        }
    }
    
}
