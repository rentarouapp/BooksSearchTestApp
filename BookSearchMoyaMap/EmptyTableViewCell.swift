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
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier )
        self.addSubview(self.emptyImageView)
        self.emptyImageView.snp.makeConstraints { make in
            make.height.width.equalTo(200)
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        
    }
    
}

