//
//  GenreCollectionViewCell.swift
//  MoviesApp
//
//  Created by ardy on 21/07/23.
//

import UIKit

class GenreCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var genreNameLabel: UILabel!
    
    static let identifier = String(describing: GenreCollectionViewCell.self)
    static let nib = {
        return UINib(nibName: identifier, bundle: nil)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        // Add corner radius to the cell
        self.layer.cornerRadius = 10.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.masksToBounds = true
        // You can also set background color here if needed
        self.backgroundColor = UIColor.clear
    }

}
