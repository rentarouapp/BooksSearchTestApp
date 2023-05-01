//
//  EmptyTableViewCell.swift
//  BookSearchMoyaMap
//
//  Created by 上條蓮太朗 on 2023/04/30.
//  Copyright © 2023 uejo. All rights reserved.
//

import UIKit
import SnapKit

class EmptyTableViewCell: UITableViewCell {
    
    private var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.addSubview(self.emptyImageView)
        self.emptyImageView.snp.makeConstraints { make in
            make.height.width.equalTo(200)
            make.center.equalToSuperview()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        
    }
    
}

