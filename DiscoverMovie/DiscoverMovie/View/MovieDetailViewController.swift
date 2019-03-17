//
//  MovieDetailViewController.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/16.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import UIKit
import SafariServices

protocol MovieDisplayDetail {
    var posterImage: URL? { get }
    var backdropImage: URL? { get }
    var title: String { get }
    var popularity: Double { get }
    var synopsis: String { get }
    var genres: String { get }
    var language: String { get }
    var duration: String { get }
}

protocol MovieDetailControlling {
    func requestFocusMovieDetail(_ completionHandler: @escaping () -> Void)
    func getFocusMovieDetail() -> MovieDisplayDetail?
    func getBookingFocusMovieURL() -> URL
    func defocusMovie()
}

class MovieDetailViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var backdropImageVConstraint: NSLayoutConstraint!
    
    lazy var controller: MovieDetailControlling = MainApp.shared
    private(set) var contentTableVC: MovieDetailContentTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Book me", style: .plain, target: self, action: #selector(clickBookMovie))
        
        backdropImageView.alpha = 0.3
        
        loadBackdrop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.2) {
            self.backdropImageView.alpha = 0.3
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            controller.defocusMovie()
            
            UIView.animate(withDuration: 0.2) {
                self.backdropImageView.alpha = 0
            }
        }
    }
    
    @objc func clickBookMovie() {
        let safariVC = SFSafariViewController(url: controller.getBookingFocusMovieURL())
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ContentTable":
            contentTableVC = (segue.destination as! MovieDetailContentTableViewController)
            contentTableVC.controller = controller
            contentTableVC.scrollViewDidScrollHandler = { (contentOffset) in
                self.backdropImageVConstraint.constant = -(contentOffset.y / 5.0)
            }

        default:
            assertionFailure("?? \(String(describing: segue.identifier))")
            break
        }
    }
    
    // MARK: - SFSafariViewControllerDelegate
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func loadBackdrop() {
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
    
    func reloadContent() {
        contentTableVC.tableView.reloadSections([0], with: .automatic)
        loadBackdrop()
    }
    
}
