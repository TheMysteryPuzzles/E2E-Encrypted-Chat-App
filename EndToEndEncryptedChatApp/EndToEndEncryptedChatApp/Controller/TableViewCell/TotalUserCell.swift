//  Copyright © 2019 TheMysteryPuzzles. All rights reserved.

import UIKit

class TotalUserCell: UITableViewCell {
    
    var username: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var profilePic: RoundedImageView = {
        let imageView = RoundedImageView()
        imageView.image = UIImage(named: "user_Default")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(profilePic)
        NSLayoutConstraint.activate([
            profilePic.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            profilePic.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2),
            profilePic.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.9),
            profilePic.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
        
        
        self.addSubview(username)
        NSLayoutConstraint.activate([
            username.leadingAnchor.constraint(equalTo: profilePic.trailingAnchor, constant: 10),
            username.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7),
            username.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5),
            username.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  

}
