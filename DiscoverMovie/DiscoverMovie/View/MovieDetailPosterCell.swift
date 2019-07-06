//
//  MovieDetailPosterCell.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/17.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import UIKit

class MovieDetailPosterCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!

    var posterImageViewTask: URLSessionTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        
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
    
    override func prepareForReuse() {
        posterImageViewTask?.cancel()
        posterImageViewTask = nil
        
        placeholderForImageView()
        
        super.prepareForReuse()
    }
    
    private func placeholderForImageView() {
        posterImageView.image = UIImage.from(color: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0))
    }
}
