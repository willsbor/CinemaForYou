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
    func bookingFocusMove()
    func getFocusMovieDetail() -> MovieDisplayDetail?
    func defocusMovie()
}

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var backdropImageVConstraint: NSLayoutConstraint!
    
    var controller: MovieDetailControlling = MockController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Book me", style: .plain, target: self, action: #selector(clickBookMovie))
        
        backdropImageView.alpha = 0.3
        
        let item = controller.getFocusMovieDetail()
        if let url = item?.backdropImage {
            _ = ImageManager.shared.loadImageURL(url) { (data) in
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self.backdropImageView.image = UIImage(data: data)
                }
            }
        }
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
            let vc = (segue.destination as! MovieDetailContentTableViewController)
            vc.controller = controller
            vc.scrollViewDidScrollHandler = { (contentOffset) in
                self.backdropImageVConstraint.constant = -(contentOffset.y / 5.0)
            }

        default:
            assertionFailure("?? \(String(describing: segue.identifier))")
            break
        }
    }
    
}
