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
    var apiManager = ApiManager()
    var genreList = BehaviorSubject(value: [GenreData]())
    var onSuccessFetchData = PublishSubject<Bool>()
    var pageCounter = 1
    
    var bag = DisposeBag()
    
    func fetchData() {
        apiManager.fetchData(.genreList)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (data: GenreEntity) in
                guard let self = self,
                      let data = data.genres
                else {
                    self?.onSuccessFetchData.onNext(false)
                    return
                }
                print("GenreEntity: \(data)")
                self.genreList.onNext(data)
            }, onError: { error in
                // error handling
                self.onSuccessFetchData.onNext(false)
                print(error)
            }).disposed(by: bag)
    }
}
