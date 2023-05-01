//
//  BookSearchTableViewController.swift
//  BookSearchMoyaMap
//
//  Created by uejo on 2020/05/08.
//  Copyright © 2020 uejo. All rights reserved.
//

import UIKit
import Moya

class BookSearchTableViewController: UITableViewController {
    
    private let emptyCellId = "emptyTableViewCell"
    
    //一冊の本（ひとつのアイテム）の情報を格納する変数
    private var bookDataArray = [VolumeInfo]()
    
    private var isBookListAvailable: Bool {
        get {
            return !self.bookDataArray.isEmpty
        }
    }
    
    private var moyaProviders: [Cancellable] = []
    
    //キャッシュ画像を保存するための変数
    var imageCache = NSCache<AnyObject, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if self.isBookListAvailable {
            return self.bookDataArray.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isBookListAvailable {
            return 120
        } else {
            return self.tableView.bounds.size.height
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.bookDataArray.count == 0 {
            if let emptyCell = tableView.dequeueReusableCell(withIdentifier: emptyCellId) as? EmptyTableViewCell {
                self.tableView.isScrollEnabled = false
                return emptyCell
            }
            return UITableViewCell()
        }
        
        self.tableView.isScrollEnabled = true
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemTableViewCell else {
            return UITableViewCell()
        }

        let oneBookData = bookDataArray[indexPath.row]
        
        //本のタイトルを設定
        cell.titleLabel.text = oneBookData.title
        
        //本の作者を設定
        if oneBookData.authors != nil {
            //作者がいる場合の処理
            let hitAuthors = oneBookData.authors?.joined(separator: ",")
            cell.authorLabel.text = hitAuthors
        } else {
            //作者がいなかった場合
            cell.authorLabel.text = "作者なし"
        }
        
        //本のURLを設定
        cell.bookUrl = oneBookData.infoLink
        
        //サムネイル画像の設定
        guard let bookImageUrl = oneBookData.imageLinks?.smallThumbnail else {
            //画像がなかった場合の処理
            return cell
        }
        
        //キャッシュの画像を取り出す
        if let cacheImage = imageCache.object(forKey: bookImageUrl as AnyObject) {
            cell.bookImageView.image = cacheImage
        }
        //キャッシュの画像がないときのダウンロード
        guard let url = URL(string: bookImageUrl) else {
            //URLが生成できなかったときの処理
            return cell
        }
        
        //生成したURLを使って画像にアクセス
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            //エラーチェック
            guard error == nil else {
                //エラーあり
                return
            }
            
            //データを生成
            guard let data = data else {
                //データがない
                return
            }
            
            //イメージを生成
            guard let image = UIImage(data: data) else {
                //imageが生成できなかった
                return
            }
            //ダウンロードした画像をキャッシュに登録
            self.imageCache.setObject(image, forKey: bookImageUrl as AnyObject)
            
            //画像に関する処理はメインスレッドで
            DispatchQueue.main.async {
                cell.bookImageView.image = image
            }
        }
        
        //通信を開始
        task.resume()
        
        //セルを返す
        return cell
    }
    
    //画面遷移の時の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? ItemTableViewCell {
            if let webViewConrtoller = segue.destination as? WebViewController {
                //商品ページのURLを設定
                webViewConrtoller.bookUrl = cell.bookUrl
            }
        }
    }
    
    // MARK: - Common
    func resumeSearch(searchBar: UISearchBar, text: String?) {
        //現時点で保持している本のデータを一旦全て削除
        self.bookDataArray.removeAll()
        //入力文字の有無をチェック
        guard let inputText = searchBar.text, inputText.count > 0 else {
            //入力文字なし
            self.moyaProviders.forEach({ $0.cancel() })
            self.moyaProviders.removeAll()
            self.bookDataArray.removeAll()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
        
        let provider = MoyaProvider<GbaData>()
        let request = provider.request(.search(request: ["q":"\(inputText)", "maxResults":"12"])) {
            result in
            switch result {
            //通信が成功したときの処理
            case let .success(moyaResponse):
                //decodeメソッドを呼び出す
                let jsonData = try? JSONDecoder().decode(TotalItems.self, from: moyaResponse.data)
                //オブジェクトの存在を確認してから商品のリストに追加
                if let _items = jsonData?.items {
                    for item in _items {
                        if let _volumeInfo = item.volumeInfo {
                            self.bookDataArray.append(_volumeInfo)
                        }
                    }
                }
                
            //通信が失敗したときの処理
            case let .failure(error):
                print("アクセスに失敗しました:\(error)")
            }
            
            //ビューの描画をメインスレッドで行わすための処理
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            //キーボードを閉じる
            //searchBar.resignFirstResponder()
        }
        self.moyaProviders.append(request)
    }
    
    
}

extension BookSearchTableViewController: UISearchBarDelegate {
    
    // 入力中
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.resumeSearch(searchBar: searchBar, text: searchText)
    }
    
    // キャンセルボタン
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.resumeSearch(searchBar: searchBar, text: nil)
    }
    
    //検索ボタンが押されたときの処理
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.resumeSearch(searchBar: searchBar, text: searchBar.text)
    }
}
