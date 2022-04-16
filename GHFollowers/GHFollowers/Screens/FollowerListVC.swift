//
//  FollowerListVC.swift
//  GHFollowers
//
//  Created by huangxiaobin on 2022/4/5.
//

import UIKit

class FollowerListVC: UIViewController {
	
	// hashable
	enum Section {
		case main
	}
	
	var page = 1
    var username: String!
	var followers: [Follower] = []
    var filteredFollowers: [Follower] = []
	var hasMoreFollowers = true
	var collectionView: UICollectionView!
	var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		configureCollectionView()
		configureViewController()
        configureSearchController()
		getFollowers(username: username, page: page)
		configureDataSource()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(false, animated: true)
	}
	
	func getFollowers(username: String, page: Int) {
		showLoadingView()
		
		NetworkManager.shared.getFollowers(for: username, page: page) { [weak self] result in
			guard let self = self else { return }
			self.dismissLoadingView()
			
			switch result {
				
				case .success(let followers):
					if followers.count < 100 { self.hasMoreFollowers = false }
					self.followers.append(contentsOf: followers)

                    if self.followers.count < 10 {
                        let message = "This user doesn't have any followers. Go to follow them 😀."
                        DispatchQueue.main.async {
                            self.showEmptyStateView(with: message, in: self.view)
                        }
                        return
                    }

                self.updateData(on: self.followers)

				case .failure(let error):
					self.presentGFAlertOnMainThread(title: "Bad Stuff Happend", message: error.rawValue, buttonTitle: "Ok")
			}
			
		}
	}

    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater   = self
        searchController.searchBar.placeholder  = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController         = searchController
    }
	
	private func configureViewController() {
		view.backgroundColor = .systemBackground
		navigationController?.navigationBar.prefersLargeTitles = true
	}
	
	private func configureCollectionView() {
		collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
		view.addSubview(collectionView)
		collectionView.delegate = self
		collectionView.backgroundColor = .systemBackground
		collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
	}

		
	func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, follower) -> UICollectionViewCell? in
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
			cell.set(follower: follower)
			
			return cell
		})
	}
	
    func updateData(on followers: [Follower]) {
		var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
		snapshot.appendSections([Section.main])
		snapshot.appendItems(followers)
		DispatchQueue.main.async {
			self.dataSource.apply(snapshot, animatingDifferences: true)
		}
	}
}

extension FollowerListVC: UICollectionViewDelegate {
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		let offsetY			= scrollView.contentOffset.y
		let contentHeight 	= scrollView.contentSize.height
		let height			= scrollView.frame.size.height
		
//		print(offsetY)
//		print(contentHeight)
//		print(height)
		
		if offsetY > contentHeight - height {
			guard hasMoreFollowers else { return }
			page += 1
			getFollowers(username: username, page: page)
		}
	}
}

extension FollowerListVC: UISearchResultsUpdating, UISearchBarDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else { return }
        filteredFollowers = followers.filter { $0.login.lowercased().contains(filter.lowercased()) }
        updateData(on: filteredFollowers)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateData(on: followers)
    }


}
