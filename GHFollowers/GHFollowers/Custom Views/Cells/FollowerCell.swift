//
//  FollowerCell.swift
//  GHFollowers
//
//  Created by huangxiaobin on 2022/4/9.
//

import UIKit

class FollowerCell: UICollectionViewCell {
    static let reuseID = "FollowerCell"
	
	let avatarImaegView = GFAvatarImageView(frame: .zero)
	let usernameLabel = GFTitleLabel(textAlignment: .center, fontSize: 16)
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func set(follower: Follower) {
		usernameLabel.text = follower.login
		avatarImaegView.downloadImage(from: follower.avatarUrl)
	}
	
	private func configure() {
		addSubview(avatarImaegView)
		addSubview(usernameLabel)
		
		let padding: CGFloat = 8
		
		NSLayoutConstraint.activate([
			avatarImaegView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
			avatarImaegView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
			avatarImaegView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
			avatarImaegView.heightAnchor.constraint(equalTo: avatarImaegView.widthAnchor),
			
			usernameLabel.topAnchor.constraint(equalTo: avatarImaegView.bottomAnchor, constant: 12),
			usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
			usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
			usernameLabel.heightAnchor.constraint(equalToConstant: 20),
		])
	}
}
