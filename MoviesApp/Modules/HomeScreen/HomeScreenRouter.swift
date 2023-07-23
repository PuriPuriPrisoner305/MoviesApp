//
//  HomeScreenRouter.swift
//  MoviesApp
//
//  Created by ardy on 22/07/23.
//

import UIKit

class HomeScreenRouter {
    func navigateToDiscover(navigation: UINavigationController, genre: GenreData) {
        let storyboardId = String(describing: DiscoverMovieView.self)
        let storyboard = UIStoryboard(name: storyboardId, bundle: nil)
        guard let view = storyboard.instantiateViewController(withIdentifier: storyboardId) as? DiscoverMovieView else {
            fatalError(ErrorType.storyboardLoadFailed.description)
        }
        view.navigationItem.title = genre.name
        view.genre = genre.id ?? 0
        navigation.pushViewController(view, animated: true)
    }
}
