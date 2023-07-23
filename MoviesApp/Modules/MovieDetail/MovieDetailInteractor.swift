//
//  MovieDetailInteractor.swift
//  MoviesApp
//
//  Created by ardy on 23/07/23.
//

import Foundation
import RxSwift

class MovieDetailInteractor: BaseInteractor {
    func fetchMovieDetail(id: Int) -> Observable<MovieDetailEntity?> {
        api.fetchData(.movieDetail(id: id))
    }
    
    func getImageUrl(_ url: String) -> URL? {
        api.getImageUrl(url)
    }
}
