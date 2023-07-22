//
//  HomeScreenView.swift
//  MoviesApp
//
//  Created by ardy on 21/07/23.
//

import UIKit
import RxSwift
import RxCocoa

class HomeScreenView: UIViewController {
    @IBOutlet weak var genreCollectionView: UICollectionView!
    
    var presenter = HomeScreenPresenter()
    var bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        registerDataBinding()
        presenter.fetchData()
        // Do any additional setup after loading the view.
    }

    //MARK: listening to movielist observable object and populate the collectionview
    func registerDataBinding() {
        genreCollectionView.register(GenreCollectionViewCell.nib, forCellWithReuseIdentifier: GenreCollectionViewCell.identifier)
        presenter.genreList.bind(
            to: genreCollectionView.rx.items(
                cellIdentifier: GenreCollectionViewCell.identifier,
                cellType: GenreCollectionViewCell.self)) { (index, item, cell) in
                    cell.genreNameLabel.text = item.name ?? "-"
            }
            .disposed(by: bag)
        
        genreCollectionView.rx.setDelegate(self).disposed(by: bag)
    }
    
    func setupAction() {
        presenter.onSuccessFetchData
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                print("genreList: \(presenter.genreList)")
            }).disposed(by: bag)
    }
    
    func setupView() {
        // setup background
        genreCollectionView.backgroundColor = UIColor.clear
        
        // setup navigation
        navigationItem.title = "Genres"
    }
}

extension HomeScreenView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = 30 + (flowLayout.minimumInteritemSpacing * CGFloat(1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(2))
        
        return CGSize(width: size, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
}
