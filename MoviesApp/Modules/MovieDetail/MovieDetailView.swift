//
//  MovieDetailView.swift
//  MoviesApp
//
//  Created by ardy on 23/07/23.
//

import UIKit
import SkeletonView
import RxSwift
import YouTubePlayer
import Network
import Kingfisher

class MovieDetailView: UIViewController {
    @IBOutlet weak var movieDetailView: UIScrollView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var reviewCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    @IBOutlet weak var overviewDetailLabel: UILabel!
    @IBOutlet weak var overviewInfoLabel: UILabel!
    @IBOutlet weak var videoPlayer: YouTubePlayerView!
    @IBOutlet weak var trailerView: UIView!
    @IBOutlet weak var emptyReviewLabel: UILabel!
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    var presenter = MovieDetailPresenter()
    var apiManager = ApiManager()
    var movieID = 0
    let bag = DisposeBag()
    var timer: Timer?
    var monitor = NWPathMonitor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupAction()
        setupVideoPlayer()
        setupNetworkMonitor()
        isShowingSkeleton(true)
    }
    // fetch movie data
    func fetchDetailData() {
        presenter.fetchMovieDetail(id: movieID)
    }
    
    func setupAction() {
        retryButton.rx.tapGesture()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.fetchDetailData()
            }).disposed(by: bag)
        
        presenter.onSuccessFetchData
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                if value {
                    self.imageCollectionView.reloadData()
                    self.reviewCollectionView.reloadData()
                    self.setupView()
                    self.setupPageView()
                    self.setupVideoPlayer()
                    self.isShowingSkeleton(false)
                }
                self.setupErrorView(isError: !value)

            }).disposed(by: bag)
    }
    
    func isShowingSkeleton(_ value: Bool) {
        if value {
            movieDetailView.showGradientSkeleton(animated: true, delay: 0)
            imageCollectionView.showGradientSkeleton(animated: true, delay:0)
            reviewCollectionView.showGradientSkeleton(animated: true, delay:0)
        } else {
            movieDetailView.hideSkeleton()
            imageCollectionView.hideSkeleton()
            setupTimer()
        }

    }
    
    func setupCollectionView() {
        imageCollectionView.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.identifier)
        reviewCollectionView.register(ReviewCell.nib, forCellWithReuseIdentifier: ReviewCell.identifier)

    }
    
    func setupView() {
        overviewDetailLabel.text = presenter.movieDetail?.overview ?? "-"
        overviewInfoLabel.text = presenter.getOverviewInfo()
    }
    
    func setupPageView() {
        self.pageView.currentPage = 0
        self.pageView.numberOfPages = presenter.imageUrl.count
    }
    
    //MARK: setup timer for movie images auto scroll
    func setupTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            guard let currentIndexPath = self.imageCollectionView.indexPathsForVisibleItems.first else { return }
            let nextItemIndex = currentIndexPath.item + 1 < self.presenter.imageUrl.count ? (currentIndexPath.item + 1) % (self.presenter.movieDetail?.images?.backdrops?.count ?? 0) : 0
            let nextIndexPath = nextItemIndex <= self.presenter.imageUrl.count ? IndexPath(item: nextItemIndex, section: 0) : IndexPath(item: 0, section: 0)
            self.imageCollectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
            self.pageView.currentPage = nextItemIndex
        }
        timer?.fire()
    }
    
    //MARK: setup youtube video player
    func setupVideoPlayer() {
        guard let result = presenter.movieDetail?.videos?.results else { return }
        for data in result {
            guard let type = data.type,
                  let site = data.site
            else { return }
            if type.lowercased() == "trailer" && site.lowercased() == "youtube" {
                guard let key = data.key,
                      let videoUrl = URL(string: "ttps://www.youtube.com/watch?v=\(key)")
                else { return }
                DispatchQueue.main.async {
                    self.videoPlayer.loadVideoURL(videoUrl)
                }
                break
            }
        }
    }
    
    //MARK: Setup error view
    func setupErrorView(isError: Bool) {
        if isError {
            self.movieDetailView.isHidden = true
            self.errorView.isHidden = false
            self.errorLabel.text = ErrorType.fetchFailed.description
            self.retryButton.isHidden = false
        } else {
            self.movieDetailView.isHidden = false
            self.errorView.isHidden = true
        }
    }
    
    // MARK: Network status monitoring
    // When compile it on simulator may behave oddly. Works well with real devices
    func setupNetworkMonitor() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    print(GeneralType.networkConnected.description)
                    self.movieDetailView.isHidden = false
                    self.errorView.isHidden = true
                    self.fetchDetailData()
                } else {
                    print(GeneralType.networkDisconnected.description)
                    self.movieDetailView.isHidden = true
                    self.errorView.isHidden = false
                    self.errorLabel.text = ErrorType.noInternet.description
                    self.retryButton.isHidden = true
                }
            }
            print(path.isExpensive)
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }

}

extension MovieDetailView: SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        if skeletonView == imageCollectionView {
            return ImageCell.identifier
        } else {
            return ReviewCell.identifier
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == imageCollectionView {
            return presenter.imageUrl.count
        } else if collectionView == reviewCollectionView {
            let data = presenter.reviewData
            reviewCollectionView.isHidden = data.isEmpty
            emptyReviewLabel.isHidden = !data.isEmpty
            return presenter.reviewData.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == imageCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
            cell.imageView.kf.indicatorType = .activity
            cell.imageView.kf.setImage(with: presenter.imageUrl[indexPath.row])
            return cell
        } else if collectionView == reviewCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCell.identifier, for: indexPath) as! ReviewCell
            
            guard let data = presenter.reviewData[indexPath.row] else { return UICollectionViewCell() }
            cell.authorNameLabel.text = data.author ?? "-"
            cell.reviewLabel.text = data.content ?? "-"
            let url = apiManager.getAvatarUrl(presenter.reviewData[indexPath.row]?.authorDetails?.avatarPath ?? "")
            cell.avatarImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person.fill"))
            if let rating = presenter.reviewData[indexPath.row]?.authorDetails?.rating {
                cell.ratingLabel.text = "★ \(String(format: "%.1f", rating))"
            } else {
                cell.ratingView.isHidden = true
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == imageCollectionView {
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        } else if collectionView == reviewCollectionView {
            return CGSize(width: collectionView.frame.size.width - 30, height: 300)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == imageCollectionView {
            return 0
        }
        return 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let view = scrollView as? UICollectionView
        if view == imageCollectionView {
            let contentOffset = imageCollectionView.contentOffset
            let pageWidth = imageCollectionView.bounds.width
            let currentPage = Int(round(contentOffset.x / pageWidth))
            pageView.currentPage = currentPage
        }
    }
}
