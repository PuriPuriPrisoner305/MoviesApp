//
//  DiscoverMoviePresenter.swift
//  MoviesApp
//
//  Created by ardy on 22/07/23.
//

import Foundation
import RxSwift

class DiscoverMoviePresenter {
    var apiManager = ApiManager()
    var movieList = BehaviorSubject(value: [MovieEntity]())
    var onSuccessFetchData = PublishSubject<Bool>()
    var pageCounter = 1
    
    var interactor = DiscoverMovieInteractor()
    var router = DiscoverMovieRouter()
    var bag = DisposeBag()
    
    // MARK: API Call for movies discover
    func fetchData(genre: Int) {
        interactor.fetchDiscoverMovie(genre: genre, pageCounter: pageCounter)
        .subscribe(onNext: { [weak self] data in
            guard let self = self,
                  let data = data.results
            else {
                self?.onSuccessFetchData.onNext(false)
                return
            }
            do {
                try self.movieList.onNext(self.movieList.value() + data)
                self.onSuccessFetchData.onNext(true)
            } catch {
                // error handling
                print(ErrorType.decodingFailed.description + ": \(error)")
                self.onSuccessFetchData.onNext(false)
            }
            self.pageCounter += 1
        }, onError: { error in
            // error handling
            self.onSuccessFetchData.onNext(false)
            print(error)
        }).disposed(by: bag)
    }
}

// MARK: Navigator
extension DiscoverMoviePresenter {
    func navigateToMovieDetailView(id: Int, title: String, from navigation: UINavigationController) {
        router.navigateToMovieDetailView(id: id, title: title, from: navigation)
    }
}
