//
//  BookDetailViewController.swift
//  BookSearchMoyaMap
//
//  Created by 上條蓮太朗 on 2023/05/06.
//  Copyright © 2023 uejo. All rights reserved.
//

import UIKit

class BookDetailViewController: UIViewController {
    
    var bookData: BookItem?
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var publishDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _bookData = bookData?.volumeInfo {
            self.navigationItem.title = _bookData.title
            self.titleLabel.text = _bookData.title
            self.authorLabel.text = _bookData.authors?.first ?? "作者なし"
            self.publishDateLabel.text = _bookData.publishedDate ?? "発刊年月日なし"
            self.descriptionTextView.text = _bookData.description ?? "※この本に関しての説明はありません"
            self.descriptionTextView.sizeToFit()
            
            if let bookImageUrl = _bookData.imageLinks?.thumbnail {
                // キャッシュ画像がなければ
                guard let url = URL(string: bookImageUrl) else {
                    //URLが生成できなかったときの処理
                    self.thumbnailImageView.image = UIImage(named: "no_image")
                    return
                }
                //生成したURLを使って画像にアクセス
                let request = URLRequest(url: url)
                let session = URLSession.shared
                let task = session.dataTask(with: request) {
                    (data: Data?, response: URLResponse?, error: Error?) in
                    
                    guard error == nil, let data = data, let image = UIImage(data: data) else {
                        // 例外チェック
                        self.thumbnailImageView.image = UIImage(named: "no_image")
                        return
                    }
                    //画像に関する処理はメインスレッドで
                    DispatchQueue.main.async {
                        self.thumbnailImageView.image = image
                    }
                }
                //通信を開始
                task.resume()
            } else {
                self.thumbnailImageView.image = UIImage(named: "no_image")
            }
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        print("uejo_tapped")
    }
    
    @IBAction func webButtonTapped(_ sender: Any) {
        if let urlString = bookData?.volumeInfo?.infoLink, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
}
