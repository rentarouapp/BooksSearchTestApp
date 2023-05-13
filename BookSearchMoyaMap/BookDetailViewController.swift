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
    
    let realmManager = RealmManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _bookData = bookData, let _volumeInfo = _bookData.volumeInfo {
            self.navigationItem.title = _volumeInfo.title
            self.titleLabel.text = _volumeInfo.title
            self.authorLabel.text = _volumeInfo.authors?.first == nil || _volumeInfo.authors?.first == "" ? "作者なし" : _volumeInfo.authors?.first
            self.publishDateLabel.text = _volumeInfo.publishedDate == nil || _volumeInfo.publishedDate == "" ? "発刊年月日なし" : _volumeInfo.publishedDate
            self.descriptionTextView.text = _volumeInfo.description == nil || _volumeInfo.description == "" ? "※この本に関しての説明はありません" : _volumeInfo.description
            self.descriptionTextView.sizeToFit()
            
            if let _bookId = _bookData.id, self.realmManager.isFavorite(id: _bookId) {
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
        self.favoriteButton.layer.borderWidth = isFavorite ? 2.0 : 0.0
        self.favoriteButton.layer.borderColor = isFavorite ? onTintColor.cgColor : UIColor.clear.cgColor
        self.favoriteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.favoriteButton.setTitle(isFavorite ? "お気に入りから削除する" : "お気に入りに追加する", for: .normal)
        let buttonImage = isFavorite ? UIImage.init(systemName: "trash") : UIImage.init(systemName: "star.fill")
        self.favoriteButton.setImage(buttonImage, for: .normal)
        self.favoriteButton.tintColor = isFavorite ? onTintColor : offTintColor
    }
    
    func realmUpdateAction(isFavorite: Bool, completion: @escaping () -> (Void)) {
        guard let _bookItem = self.bookData, let _bookId = self.bookData?.id else { return }
        if self.realmManager.isFavorite(id: _bookId) {
            // お気に入り登録されていたら削除
            self.realmManager.deleteBookData(id: _bookId, completion: { [weak self] error in
                guard let `self` = self else { return }
                if let _error = error {
                    AlertManager.showErrorAlert(self, error: _error)
                    return
                }
                completion()
            })
            
        } else {
            // お気に入り登録されていなかったら登録
            self.realmManager.writeBookData(bookItem: _bookItem, completion: { [weak self] error in
                guard let `self` = self else { return }
                if let _error = error {
                    AlertManager.showErrorAlert(self, error: _error)
                    return
                }
                completion()
            })
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        let realmUpdatedCompletion: () -> Void = { [weak self] in
            guard let `self` = self, let _bookId = self.bookData?.id else { return }
            if self.realmManager.isFavorite(id: _bookId) {
                // お気に入りに登録されたら
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    AlertManager.showAlertIn(self, title: "お気に入り登録", message: "お気に入り登録が完了しました！", cancelText: "閉じる", doneText: nil, cancelCompletion: {
                        self.setFavoriteButton(isFavorite: true)
                    }, doneCompletion: nil)
                }
            } else {
                // お気に入りから削除されたら
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    AlertManager.showAlertIn(self, title: "お気に入り削除", message: "お気に入りから削除しました！", cancelText: "閉じる", doneText: nil, cancelCompletion: {
                        self.setFavoriteButton(isFavorite: true)
                        // 前の画面に戻る
                        self.navigationController?.popViewController(animated: true)
                    }, doneCompletion: nil)
                }
            }
        }
        guard let _bookId = self.bookData?.id else { return }
        let isFavorite: Bool = self.realmManager.isFavorite(id: _bookId)
        if isFavorite {
            // 削除だったらアラートを出してから
            AlertManager.showAlertIn(self, title: "削除", message: "\(self.bookData?.volumeInfo?.title ?? "")をお気に入りから削除してよいですか？", cancelText: "いいえ", doneText: "削除", isDelete: true, cancelCompletion: nil, doneCompletion: { [weak self] in
                guard let `self` = self else { return }
                self.realmUpdateAction(isFavorite: isFavorite, completion: realmUpdatedCompletion)
            })
        } else {
            self.realmUpdateAction(isFavorite: isFavorite, completion: realmUpdatedCompletion)
        }
    }
    
    @IBAction func webButtonTapped(_ sender: Any) {
        if let urlString = bookData?.volumeInfo?.infoLink, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
}
