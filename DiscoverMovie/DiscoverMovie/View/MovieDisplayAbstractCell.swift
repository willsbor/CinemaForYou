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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backdropImageView.alpha = 0.5
        
        posterImageView.layer.cornerRadius = 5.0
        posterImageView.layer.shadowColor = UIColor.white.cgColor
        posterImageView.layer.shadowRadius = 2.0
        posterImageView.layer.shadowOffset = CGSize(width: 2, height: 2)
        posterImageView.layer.shadowOpacity = 1.0
        
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
    }
    
}
