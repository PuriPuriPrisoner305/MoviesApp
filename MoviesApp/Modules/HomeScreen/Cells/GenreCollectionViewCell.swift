//
//  GenreCollectionViewCell.swift
//  MoviesApp
//
//  Created by ardy on 21/07/23.
//

import UIKit
import RxSwift

protocol GenreCellDelegate {
    func didTap(genre: GenreData)
}

class GenreCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var genreNameLabel: UILabel!
    
    static let identifier = String(describing: GenreCollectionViewCell.self)
    static let nib = {
        return UINib(nibName: identifier, bundle: nil)
    }()
    
    var genreData: GenreData?
    var delegate: GenreCellDelegate?
    var bag = DisposeBag()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        setupAction()
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
    
    func setupAction() {
        self.contentView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard let data = genreData else { return }
                self.delegate?.didTap(genre: data)
            }).disposed(by: bag)
    }

}
