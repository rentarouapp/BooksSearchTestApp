//
//  FavoriteListViewController.swift
//  BookSearchMoyaMap
//
//  Created by 上條蓮太朗 on 2023/05/12.
//  Copyright © 2023 uejo. All rights reserved.
//

import UIKit

class FavoriteListViewController: UIViewController {
    
    var favoriteBookDataArray: [BookItem] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var emptyView: EmptyView = {
        let view = EmptyView()
        view.textLabel.text = "お気に入りされている本はないよ"
        return view
    }()
    
    var editBarButtonItem: UIBarButtonItem = UIBarButtonItem()
    
    //キャッシュ画像を保存するための変数
    var imageCache = NSCache<AnyObject, UIImage>()
    
    let realmManager = RealmManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 検索結果なしView
        self.view.addSubview(self.emptyView)
        self.emptyView.snp.makeConstraints { make in
            make.top.equalTo(self.tableView)
            make.left.right.bottom.equalTo(self.tableView)
        }
        
        // 引っ張って更新
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: UIControl.Event.valueChanged)
        self.tableView.refreshControl = refreshControl
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 120
        
        // 編集ボタン
        self.editButtonItem.title = "編集"
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 14.0, *) {
            self.navigationItem.backButtonDisplayMode = .minimal
        } else {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        self.navigationItem.title = "お気に入り一覧"
        self.loadData()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.isEditing = editing
        self.editButtonItem.title = editing ? "キャンセル" : "編集"
    }
    
    private func loadData() {
        self.favoriteBookDataArray = self.realmManager.getRealmAllBookData().reversed()
        if self.favoriteBookDataArray.isEmpty {
            self.emptyView.isHidden = false
            return
        } else {
            self.emptyView.isHidden = true
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Common
    @objc func refreshTableView() {
        // 引っ張って更新
        self.tableView.refreshControl?.endRefreshing()
        self.loadData()
    }
    
}

extension FavoriteListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoriteBookDataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemTableViewCell else {
            return UITableViewCell()
        }
        guard let oneBookData = self.favoriteBookDataArray[indexPath.row].volumeInfo else {
            return UITableViewCell()
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let _nav = self.navigationController,
           let bookData = self.favoriteBookDataArray[safe: indexPath.row],
           let vc = self.storyboard?.instantiateViewController(withIdentifier: "BookDetailViewController") as? BookDetailViewController {
            vc.bookData = bookData
            _nav.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if let _bookId = self.favoriteBookDataArray[safe: indexPath.row]?.id, self.realmManager.isFavorite(id: _bookId) {
            // お気に入り登録されていることを確認して削除
            IndicatorManager.show()
            self.realmManager.deleteBookData(id: _bookId, completion: { [weak self] error in
                IndicatorManager.hide()
                guard let `self` = self else { return }
                if let _error = error {
                    AlertManager.showErrorAlert(self, error: _error)
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    self.favoriteBookDataArray.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    AlertManager.showAlertIn(self, title: "お気に入り削除", message: "お気に入りから削除しました！", cancelText: "閉じる", doneText: nil, cancelCompletion: nil, doneCompletion: nil)
                }
            })
        }
    }
}

