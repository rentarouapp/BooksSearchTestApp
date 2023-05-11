//
//  BookDetailViewController.swift
//  BookSearchMoyaMap
//
//  Created by 上條蓮太朗 on 2023/05/06.
//  Copyright © 2023 uejo. All rights reserved.
//

import UIKit

class BookDetailViewController: UIViewController {
    
    var bookData: VolumeInfo?
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var publishDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _bookData = bookData {
            self.navigationItem.title = _bookData.title
            self.titleLabel.text = _bookData.title
            self.authorLabel.text = _bookData.authors?.first
            self.publishDateLabel.text = _bookData.publishedDate
            self.descriptionTextView.text = _bookData.description
            self.descriptionTextView.sizeToFit()
        }
    }
    
}
