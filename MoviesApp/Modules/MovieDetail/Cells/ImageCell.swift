//
//  ImageCell.swift
//  MoviesApp
//
//  Created by ardy on 23/07/23.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    static let identifier = String(describing: ImageCell.self)
    static let nib = {
        return UINib(nibName: identifier, bundle: nil)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}
