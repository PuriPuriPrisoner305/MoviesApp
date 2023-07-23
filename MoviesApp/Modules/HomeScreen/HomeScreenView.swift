//
//  HomeScreenView.swift
//  MoviesApp
//
//  Created by ardy on 21/07/23.
//

import UIKit
import RxSwift
import RxCocoa
import Network

class HomeScreenView: UIViewController {
    @IBOutlet weak var genreView: UIView!
    @IBOutlet weak var genreCollectionView: UICollectionView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    var presenter = HomeScreenPresenter()
    var bag = DisposeBag()
    var monitor = NWPathMonitor()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        setupAction()
        setupNetworkMonitor()
        setupView()
        registerDataBinding()
    }

    //MARK: listening to movielist observable object and populate the collectionview
    func registerDataBinding() {
        genreCollectionView.register(GenreCollectionViewCell.nib, forCellWithReuseIdentifier: GenreCollectionViewCell.identifier)
        presenter.genreList.bind(
            to: genreCollectionView.rx.items(
                cellIdentifier: GenreCollectionViewCell.identifier,
                cellType: GenreCollectionViewCell.self)) { (index, item, cell) in
                    cell.genreNameLabel.text = item.name ?? "-"
                    cell.genreData = item
                    cell.delegate = self
            }
            .disposed(by: bag)
        
        genreCollectionView.rx.setDelegate(self).disposed(by: bag)
    }
    
    func setupAction() {
        retryButton.rx.tapGesture()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.presenter.fetchData()
            }).disposed(by: bag)
        
        presenter.onSuccessFetchData
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                self.genreView.isHidden = !value
                self.errorView.isHidden = value
                self.retryButton.isHidden = value
                self.errorLabel.text = ErrorType.fetchFailed.description
            }).disposed(by: bag)
    }
    
    func setupView() {
        // setup background
        genreCollectionView.backgroundColor = UIColor.clear
        
        // setup navigation
        navigationItem.title = "Genres"
    }
    
    func setupNetworkMonitor() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    print(GeneralType.networkConnected.description)
                    self.genreView.isHidden = false
                    self.errorView.isHidden = true
                    self.presenter.fetchData()
                } else {
                    print(GeneralType.networkDisconnected.description)
                    self.genreView.isHidden = true
                    self.errorView.isHidden = false
                    self.errorLabel.text = ErrorType.noInternet.description
                    self.retryButton.isHidden = true
                }
            }
            print(path.isExpensive)
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}

extension HomeScreenView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = 30 + (flowLayout.minimumInteritemSpacing * CGFloat(1))
        var size = Int((collectionView.bounds.width - totalSpace) / CGFloat(2))
        size = size <= 0 ? 0 : size
        return CGSize(width: size, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
}

extension HomeScreenView: GenreCellDelegate {
    func didTap(genre: GenreData) {
        guard let navigation = navigationController else { return }
        presenter.navigateToDiscover(navigation: navigation, genre: genre)
    }
}
