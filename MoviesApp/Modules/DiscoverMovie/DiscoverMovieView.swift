//
//  DiscoverMovieView.swift
//  MoviesApp
//
//  Created by ardy on 22/07/23.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import RxGesture

class DiscoverMovieView: UIViewController {

    @IBOutlet weak var movieCollectionView: UICollectionView!
    
    var apiManager = ApiManager()
    var bag = DisposeBag()
    var presenter = DiscoverMoviePresenter()
    var genre: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        registerDataBinding()
        presenter.fetchData(genre: genre)
    }
    
    func registerDataBinding() {
        movieCollectionView.register(MovieCell.nib, forCellWithReuseIdentifier: MovieCell.identifier)
        presenter.movieList.bind(
            to: movieCollectionView.rx.items(
                cellIdentifier: MovieCell.identifier,
                cellType: MovieCell.self)) { [weak self] (_, item, cell) in
                    guard let self = self else { return }
                    cell.backgroundColor = UIColor.clear
                    cell.posterImage.kf.indicatorType = .activity
                    cell.posterImage.kf.setImage(with: self.apiManager.getImageUrl(item.posterImage ?? ""))
                    cell.titleLabel.text = item.title ?? "-"
                    cell.movieId = item.id ?? 0
                    cell.delegate = self
            }
            .disposed(by: bag)
        
        // fetch next page's data when user scrolled to bottom
        movieCollectionView.rx.willDisplayCell
            .subscribe { _, indexPath in
                let lastSection = self.movieCollectionView.numberOfSections - 1
                let lastRow = self.movieCollectionView.numberOfItems(inSection: lastSection) - 1
                if indexPath.section == lastSection && indexPath.row == lastRow {
                    self.presenter.fetchData(genre: self.genre)
                }
            }.disposed(by: bag)
        
        movieCollectionView.rx.setDelegate(self).disposed(by: bag)
    }
    
}

//MARK: CollectionView delegation
extension DiscoverMovieView: UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = 30 + (flowLayout.minimumInteritemSpacing * CGFloat(1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(2))
        
        return CGSize(width: size, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
}

//MARK: MovieCell method delegation
extension DiscoverMovieView: MovieCellDelegate {
    func didTap(id: Int, title: String) {
        guard let navigation = self.navigationController else { return }
        presenter.navigateToMovieDetailView(id: id, title: title, from: navigation)
    }
}


