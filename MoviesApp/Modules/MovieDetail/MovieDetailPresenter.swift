//
//  MovieDetailPresenter.swift
//  MoviesApp
//
//  Created by ardy on 23/07/23.
//

import Foundation
import RxSwift

class MovieDetailPresenter {
    let bag = DisposeBag()
    let onSuccessFetchData = PublishSubject<Bool>()
    
    var movieDetail: MovieDetailEntity?
    var imageUrl = [URL?]()
    var reviewData = [ReviewResultEntity?]()
    
    var interactor = MovieDetailInteractor()
    
    func fetchMovieDetail(id: Int) {
        interactor.fetchMovieDetail(id: id)
            .subscribe(onNext: { [weak self] data in
                guard let self = self,
                      let data = data
                else {
                    self?.onSuccessFetchData.onNext(false)
                    return
                }
                self.movieDetail = data
                self.imageUrl = self.getImageUrl(self.movieDetail?.images?.backdrops)
                self.reviewData = self.getReviewData(data.reviews?.results) ?? []
                self.onSuccessFetchData.onNext(true)
            }, onError: { error in
                // error handling
                self.onSuccessFetchData.onNext(false)
                print(error)
            }).disposed(by: bag)
    }
    
    func getImageUrl(_ data: [ImageBackdropEntity]?) -> [URL?] {
        
        guard let data = data,
              data.count > 0
        else { return [] }
        var imageUrl = [URL?]()
        for i in 0...data.count - 1 {
            if i >= 10 { break }
            let url = interactor.getImageUrl(data[i].filePath ?? "")
            imageUrl.append(url)
        }
        
        return imageUrl
    }
    
    func getReviewData(_ data: [ReviewResultEntity]?) -> [ReviewResultEntity]? {
        guard let data = data,
              data.count > 0
        else { return [] }
        var dataArray: [ReviewResultEntity]
        dataArray = data.count >= 5 ? Array(data.prefix(5)) : data
        
        return dataArray
    }
    
    func getOverviewInfo() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: movieDetail?.releaseDate ?? "")
        if Locale.current.languageCode == "id" {
            dateFormatter.locale = Locale(identifier: "id_ID")
        } else {
            dateFormatter.locale = Locale(identifier: "en_ID")
        }
        dateFormatter.dateFormat = "yyyy"
        
        let year = dateFormatter.string(from: date ?? Date())
        let info = "\(movieDetail?.genres?[0].name ?? "-") · \(year) · \(movieDetail?.runtime ?? 0) minutes"
        return info
    }
}
