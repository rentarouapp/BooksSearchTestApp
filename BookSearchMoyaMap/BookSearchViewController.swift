//
//  BookSearchViewController.swift
//  BookSearchMoyaMap
//
//  Created by 上條蓮太朗 on 2023/05/05.
//  Copyright © 2023 uejo. All rights reserved.
//

import UIKit
import Moya
import SnapKit

class BookSearchViewController: UIViewController {
    
    //一冊の本（ひとつのアイテム）の情報を格納する変数
    private var bookDataArray = [VolumeInfo]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var isBookListAvailable: Bool {
        get {
            return !self.bookDataArray.isEmpty
        }
    }
    
    private var moyaProviders: [Cancellable] = []
    
    private lazy var emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    private lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        //完了ボタンを作成
        let doneButton = UIBarButtonItem(title: "キャンセル",
                                   style: .done,
                                   target: self,
                                   action: #selector(didTapCancelButton))
        toolBar.items = [doneButton]
        toolBar.sizeToFit()
        return toolBar
    }()
    
    //キャッシュ画像を保存するための変数
    var imageCache = NSCache<AnyObject, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 検索結果なしView
        self.view.addSubview(self.emptyView)
        self.emptyView.snp.makeConstraints { make in
            make.top.equalTo(self.tableView).inset(self.searchBar.bounds.size.height)
            make.left.right.bottom.equalTo(self.tableView)
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.searchTextField.inputAccessoryView = self.toolBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.tableView.reloadData()
    }
    
    // MARK: - Common
    @objc func didTapCancelButton(_ sender: UIButton) {
        self.searchBar.searchTextField.resignFirstResponder()
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
            
            if self.bookDataArray.isEmpty {
                self.tableView.isHidden = true
                self.emptyView.isHidden = false
            } else {
                self.tableView.isHidden = false
                self.emptyView.isHidden = true
                //ビューの描画をメインスレッドで行わすための処理
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    self.tableView.reloadData()
                }
            }
            
        }
        self.moyaProviders.append(request)
    }
    
    
}

extension BookSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.bookDataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
}

extension BookSearchViewController: UISearchBarDelegate {
    
    // 入力中
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //self.resumeSearch(searchBar: searchBar, text: searchText)
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
