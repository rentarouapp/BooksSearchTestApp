//
//  EmptyView.swift
//  BookSearchMoyaMap
//
//  Created by 上條蓮太朗 on 2023/05/05.
//  Copyright © 2023 uejo. All rights reserved.
//

import UIKit

class EmptyView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    init() {
        super.init(frame: .zero)
        
        if let view = UINib(nibName: "EmptyView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            view.frame = bounds
            addSubview(view)
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        imageView.image = UIImage(named: "search-man")
        imageView.contentMode = .scaleAspectFit
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
}
