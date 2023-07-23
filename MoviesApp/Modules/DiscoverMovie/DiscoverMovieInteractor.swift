//
//  DiscoverMovieInteractor.swift
//  MoviesApp
//
//  Created by ardy on 23/07/23.
//

import Foundation
import RxSwift

class DiscoverMovieInteractor: BaseInteractor {
    func fetchDiscoverMovie(genre: Int, pageCounter: Int) -> Observable<MovieDiscoverEntity> {
        api.fetchData(.movieDiscover(genre: genre, page: pageCounter))
    }
}
