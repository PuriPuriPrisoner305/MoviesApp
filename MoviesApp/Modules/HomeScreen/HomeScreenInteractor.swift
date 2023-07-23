//
//  HomeScreenInteractor.swift
//  MoviesApp
//
//  Created by ardy on 22/07/23.
//

import Foundation
import RxSwift

class HomeScreenInteractor: BaseInteractor {
    
    func fetchData() -> Observable<GenreEntity> {
        api.fetchData(.genreList)
    }
}
