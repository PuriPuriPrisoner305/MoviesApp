//
//  HomeScreenPresenter.swift
//  MoviesApp
//
//  Created by ardy on 21/07/23.
//

import UIKit
import RxSwift
import RxDataSources

class HomeScreenPresenter {
    var genreList = BehaviorSubject(value: [GenreData]())
    var onSuccessFetchData = PublishSubject<Bool>()
    var pageCounter = 1
    
    var interactor = HomeScreenInteractor()
    var router = HomeScreenRouter()
    var bag = DisposeBag()
    
    func fetchData() {
        interactor.fetchData()
            .subscribe(onNext: { [weak self] data in
                guard let self = self,
                      let data = data.genres
                else {
                    self?.onSuccessFetchData.onNext(false)
                    return
                }
                self.genreList.onNext(data)
            }, onError: { error in
                // error handling
                self.onSuccessFetchData.onNext(false)
                print(error)
            }).disposed(by: bag)
    }
    
    func navigateToDiscover(navigation: UINavigationController, genre: GenreData) {
        router.navigateToDiscover(navigation: navigation, genre: genre)
    }
}
