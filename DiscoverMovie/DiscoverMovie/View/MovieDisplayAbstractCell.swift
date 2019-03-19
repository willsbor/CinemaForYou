//
//  MovieDisplayAbstractCell.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/17.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import UIKit

class MovieDisplayAbstractCell: UITableViewCell {
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    var posterImageViewTask: URLSessionTask?
    var backdropImageViewTask: URLSessionTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backdropImageView.alpha = 0.5
        
        posterImageView.layer.cornerRadius = 5.0
        posterImageView.layer.shadowColor = UIColor.white.cgColor
        posterImageView.layer.shadowRadius = 2.0
        posterImageView.layer.shadowOffset = CGSize(width: 2, height: 2)
        posterImageView.layer.shadowOpacity = 1.0
        
        titleLabel.numberOfLines = 3
        titleLabel.font = UIFont.systemFont(ofSize: 25)
        titleLabel.textColor = UIColor.black
        titleLabel.layer.shadowColor = UIColor.white.cgColor
        titleLabel.layer.shadowRadius = 1.0
        titleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        titleLabel.layer.shadowOpacity = 1.0
        
        popularityLabel.font = UIFont.systemFont(ofSize: 20)
        popularityLabel.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        popularityLabel.layer.backgroundColor = UIColor.yellow.withAlphaComponent(0.2).cgColor
        popularityLabel.layer.cornerRadius = 10.0
        popularityLabel.layer.shadowColor = UIColor.yellow.cgColor
        popularityLabel.layer.shadowRadius = 10.0
        popularityLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        popularityLabel.layer.shadowOpacity = 1.0
        
        releaseDateLabel.font = UIFont.systemFont(ofSize: 14)
        releaseDateLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        
        placeholderForImageView()
    }
    
    func loadPosterImage(_ url: URL) {
        posterImageViewTask?.cancel()
        posterImageViewTask = ImageManager.shared.loadImageURL(url) { (data) in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.posterImageView.image = UIImage(data: data)
                self.posterImageViewTask = nil
            }
        }
    }
    
    func loadBackdropImage(_ url: URL) {
        backdropImageViewTask?.cancel()
        backdropImageViewTask = ImageManager.shared.loadImageURL(url) { (data) in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.backdropImageView.image = UIImage(data: data)
                self.backdropImageViewTask = nil
            }
        }
    }
    
    override func prepareForReuse() {
        backdropImageViewTask?.cancel()
        backdropImageViewTask = nil
        posterImageViewTask?.cancel()
        posterImageViewTask = nil
        
        placeholderForImageView()
        
        super.prepareForReuse()
    }
    
    private func placeholderForImageView() {
        backdropImageView.image = UIImage.from(color: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0))
        posterImageView.image = UIImage.from(color: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0))
    }
}
