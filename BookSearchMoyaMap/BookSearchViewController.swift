//
//  BookSearchViewController.swift
//  BookSearchMoyaMap
//
//  Created by 上條蓮太朗 on 2023/05/05.
//  Copyright © 2023 uejo. All rights reserved.
//

import UIKit
import Alamofire
import Moya
import SnapKit

class BookSearchViewController: UIViewController {
    
    //一冊の本（ひとつのアイテム）の情報を格納する変数
    private var bookDataArray = [BookItem]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var isBookListAvailable: Bool {
        get {
            return !self.bookDataArray.isEmpty
        }
    }
    
    let realmManager: RealmManager = RealmManager.shared
    
    private var moyaProviders: [Cancellable] = []
    
    private var emptyText: String {
        get {
            if let text = self.searchBar.text, text.count > 0 {
                return "「\(text)」\n\nでの検索結果はありませんでした。"
            }
            return "本を探せるよ！"
        }
    }
    
    private lazy var emptyView: EmptyView = {
        let view = EmptyView()
        view.textLabel.text = self.emptyText
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
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 120
        self.searchBar.searchTextField.inputAccessoryView = self.toolBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 14.0, *) {
            self.navigationItem.backButtonDisplayMode = .minimal
        } else {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        self.navigationItem.title = "本を探す"
        self.tableView.reloadData()
        
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
    private func resumeSearch(searchBar: UISearchBar, text: String?) {
        //現時点で保持している本のデータを一旦全て削除
        self.bookDataArray.removeAll()
        //入力文字の有無をチェック
        guard let inputText = searchBar.text, inputText.count > 0 else {
            //入力文字なし
            self.moyaProviders.forEach({ $0.cancel() })
            self.moyaProviders.removeAll()
            self.bookDataArray.removeAll()
            self.emptyView.isHidden = false
            self.emptyView.textLabel.text = self.emptyText
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
        self.getBookDatas(inputText: inputText)
    }
    
    private func getBookDatas(inputText: String) {
        let provider = MoyaProvider<GbaData>()
        IndicatorManager.show()
        let request = provider.request(.search(request: ["q":"\(inputText)", "maxResults":"12"])) { [weak self] result in
            IndicatorManager.hide()
            guard let `self` = self else { return }
            switch result {
            //通信が成功したときの処理
            case let .success(moyaResponse):
                //decodeメソッドを呼び出す
                let jsonData = try? JSONDecoder().decode(TotalItems.self, from: moyaResponse.data)
                //オブジェクトの存在を確認してから商品のリストに追加
                if let _items = jsonData?.items {
                    for item in _items {
                        self.bookDataArray.append(item)
                    }
                }
                self.emptyView.isHidden = !self.bookDataArray.isEmpty
                self.emptyView.textLabel.text = self.emptyText
                
            //通信が失敗したときの処理
            case let .failure(error):
                /* ネットワーク接続エラーのハンドリングを行う */
                if let error = (error.errorUserInfo["NSUnderlyingError"] as? Alamofire.AFError)?.underlyingError as? NSError,
                   error.domain == NSURLErrorDomain,
                   error.code == NSURLErrorNotConnectedToInternet ||
                    error.code == NSURLErrorTimedOut ||
                    error.code == NSURLErrorNetworkConnectionLost {
                    // ネットワーク接続エラーの場合
                    self.emptyView.textLabel.text = "ネットワーク接続が\nありません"
                    AlertManager.showAlertIn(self,
                                             title: "ネットワーク接続がありません",
                                             message: "「設定」からネットワーク接続を確認してください。",
                                             cancelText: "閉じる",
                                             doneText: "設定",
                                             cancelCompletion: nil,
                                             doneCompletion: {
                        // Wifi設定に飛ばす
                        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                           UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    })
                } else {
                    // その他のエラーの場合
                    self.emptyView.textLabel.text = "API通信エラー"
                    AlertManager.showErrorAlert(self, error: error)
                }
                self.emptyView.isHidden = false
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.tableView.reloadData()
            }
        }
        self.moyaProviders.append(request)
    }
    
    
}

extension BookSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookDataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemTableViewCell else {
            return UITableViewCell()
        }

        guard let _bookData = bookDataArray[safe: indexPath.row], let volumeInfo = _bookData.volumeInfo else {
            return UITableViewCell()
        }
        
        //本のタイトルを設定
        cell.titleLabel.text = volumeInfo.title
        
        //本の作者を設定
        if volumeInfo.authors != nil {
            //作者がいる場合の処理
            let hitAuthors = volumeInfo.authors?.joined(separator: ",")
            cell.authorLabel.text = hitAuthors
        } else {
            //作者がいなかった場合
            cell.authorLabel.text = "作者なし"
        }
        
        // お気に入りアイコン
        if let _bookId = _bookData.id {
            cell.bookmarkImageView.isHidden = self.realmManager.isFavorite(id: _bookId) ? false : true
        }
        
        //本のURLを設定
        cell.bookUrl = volumeInfo.infoLink
        
        //サムネイル画像の設定
        guard let bookImageUrl = volumeInfo.imageLinks?.smallThumbnail else {
            //画像がなかった場合の処理
            cell.bookImageView.image = UIImage(named: "no_image")
            return cell
        }
        
        if let cacheImage = imageCache.object(forKey: bookImageUrl as AnyObject) {
            //キャッシュの画像があったら
            cell.bookImageView.image = cacheImage
        } else {
            // キャッシュ画像がなければ
            guard let url = URL(string: bookImageUrl) else {
                //URLが生成できなかったときの処理
                cell.bookImageView.image = UIImage(named: "no_image")
                return cell
            }
            //生成したURLを使って画像にアクセス
            let request = URLRequest(url: url)
            let session = URLSession.shared
            let task = session.dataTask(with: request) {
                (data: Data?, response: URLResponse?, error: Error?) in
                
                guard error == nil, let data = data, let image = UIImage(data: data) else {
                    // 例外チェック
                    cell.bookImageView.image = UIImage(named: "no_image")
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
        }
        //セルを返す
        return cell
    }
    
    // セルの選択
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let _nav = self.navigationController,
           let bookData = self.bookDataArray[safe: indexPath.row],
           let vc = self.storyboard?.instantiateViewController(withIdentifier: "BookDetailViewController") as? BookDetailViewController {
            vc.bookData = bookData
            _nav.pushViewController(vc, animated: true)
        }
    }
    
}

extension BookSearchViewController: UISearchBarDelegate {
    
    // 入力中
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            /// 検索バーのバツボタンが押されたとき
            self.resumeSearch(searchBar: searchBar, text: nil)
        }
    }
    
    // キャンセルボタン
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.searchTextField.resignFirstResponder()
        self.resumeSearch(searchBar: searchBar, text: nil)
    }
    
    //検索ボタンが押されたときの処理
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.searchTextField.resignFirstResponder()
        self.resumeSearch(searchBar: searchBar, text: searchBar.text)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchBar.searchTextField.resignFirstResponder()
    }
}

