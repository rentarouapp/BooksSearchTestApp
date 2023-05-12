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
        
        if let _bookData = bookData, let _volumeInfo = _bookData.volumeInfo {
            self.navigationItem.title = _volumeInfo.title
            self.titleLabel.text = _volumeInfo.title
            self.authorLabel.text = _volumeInfo.authors?.first ?? "作者なし"
            self.publishDateLabel.text = _volumeInfo.publishedDate ?? "発刊年月日なし"
            self.descriptionTextView.text = _volumeInfo.description ?? "※この本に関しての説明はありません"
            self.descriptionTextView.sizeToFit()
            
            if let _bookId = _bookData.id, RealmManager.isAvailableRealmBookDataFromId(id: _bookId) {
                /// お気に入り登録があったら
                self.setFavoriteButton(isFavorite: true)
            } else {
                /// なければ
                self.setFavoriteButton(isFavorite: false)
            }
            
            if let bookImageUrl = _volumeInfo.imageLinks?.thumbnail {
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
    
    private func setFavoriteButton(isFavorite: Bool) {
        
        let offBackgroundColor: UIColor = UIColor.systemYellow
        let offTintColor: UIColor = UIColor.white
        
        let onBackgroundColor: UIColor = UIColor.white
        let onTintColor: UIColor = UIColor.systemYellow
        
        self.favoriteButton.backgroundColor = isFavorite ? onBackgroundColor : offBackgroundColor
        self.favoriteButton.imageView?.image = isFavorite ? UIImage.init(systemName: "heart.fill") : UIImage.init(systemName: "heart.fill")
        self.favoriteButton.imageView?.tintColor = isFavorite ? onTintColor : offTintColor
        self.favoriteButton.titleLabel?.tintColor = isFavorite ? onTintColor : offTintColor
        self.favoriteButton.layer.borderWidth = isFavorite ? 2.0 : 0.0
        self.favoriteButton.layer.borderColor = isFavorite ? onTintColor.cgColor : UIColor.clear.cgColor
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
