//  Copyright © 2019 TheMysteryPuzzles. All rights reserved.

import UIKit

class ConversationCell: UITableViewCell {
    
    lazy  var Username: UILabel = {
       let label = UILabel()
       label.font = UIFont.boldSystemFont(ofSize: 20)
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()
    
    lazy var lastMessage: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var timeStamp: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var profilePIc: RoundedImageView = {
        let view = RoundedImageView()
        view.image = UIImage(named: "user_Default")
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    lazy var showFullConversationArrowView: UIImageView = {
       let view = UIImageView()
       view.image = UIImage(named: "ic_RightArrow")
       view.translatesAutoresizingMaskIntoConstraints = false
       return view
    }()
    
    
    lazy var messageReadUnreadView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "ic_Unread")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(profilePIc)
        NSLayoutConstraint.activate([
            profilePIc.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            profilePIc.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2),
            profilePIc.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2),
            profilePIc.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        self.addSubview(Username)
        NSLayoutConstraint.activate([
            Username.leadingAnchor.constraint(equalTo: self.profilePIc.trailingAnchor, constant: 10),
            Username.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            Username.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.22),
            Username.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5)
            ])
        
        self.addSubview(timeStamp)
        NSLayoutConstraint.activate([
            timeStamp.leadingAnchor.constraint(equalTo: self.Username.trailingAnchor, constant: 5),
            timeStamp.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            timeStamp.heightAnchor.constraint(equalTo: self.Username.heightAnchor),
            timeStamp.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ])
        
        self.addSubview(lastMessage)
        NSLayoutConstraint.activate([
            lastMessage.topAnchor.constraint(equalTo: self.Username.bottomAnchor, constant: 10),
            lastMessage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            lastMessage.leadingAnchor.constraint(equalTo: self.profilePIc.trailingAnchor, constant: 10),
            lastMessage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30)
        ])
        
        self.addSubview(showFullConversationArrowView)
        NSLayoutConstraint.activate([
            showFullConversationArrowView.topAnchor.constraint(equalTo: self.lastMessage.topAnchor),
            showFullConversationArrowView.heightAnchor.constraint(equalTo: self.lastMessage.heightAnchor, multiplier: 0.4),
            showFullConversationArrowView.leadingAnchor.constraint(equalTo: self.lastMessage.trailingAnchor, constant: 2),
            showFullConversationArrowView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
            ])
        
        self.addSubview(messageReadUnreadView)
        NSLayoutConstraint.activate([
            messageReadUnreadView.bottomAnchor.constraint(equalTo: self.lastMessage.bottomAnchor),
            messageReadUnreadView.heightAnchor.constraint(equalTo: self.lastMessage.heightAnchor, multiplier: 0.4),
            messageReadUnreadView.leadingAnchor.constraint(equalTo: self.lastMessage.trailingAnchor, constant: 2),
            messageReadUnreadView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
