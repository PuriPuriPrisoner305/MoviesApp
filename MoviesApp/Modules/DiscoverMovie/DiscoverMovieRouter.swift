//
//  DiscoverMovieRouter.swift
//  MoviesApp
//
//  Created by ardy on 23/07/23.
//

import UIKit

class DiscoverMovieRouter {
    func navigateToMovieDetailView(id: Int, title: String, from navigation: UINavigationController) {
        let storyboardId = String(describing: MovieDetailView.self)
        let storyboard = UIStoryboard(name: storyboardId, bundle: nil)
        guard let view = storyboard.instantiateViewController(withIdentifier: storyboardId) as? MovieDetailView else {
            fatalError(ErrorType.storyboardLoadFailed.description)
        }
        view.navigationItem.title = title
        view.movieID = id
        navigation.pushViewController(view, animated: true)
    }
}
