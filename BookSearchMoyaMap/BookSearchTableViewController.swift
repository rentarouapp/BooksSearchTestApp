//
//  BookSearchTableViewController.swift
//  BookSearchMoyaMap
//
//  Created by uejo on 2020/05/08.
//  Copyright © 2020 uejo. All rights reserved.
//

import UIKit
import Moya

class BookSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    private let emptyCellId = "emptyTableViewCell"
    
    //一冊の本（ひとつのアイテム）の情報を格納する変数
    private var bookDataArray = [VolumeInfo]()
    
    private var isBookListAvailable: Bool {
        get {
            return !self.bookDataArray.isEmpty
        }
    }
    
    //キャッシュ画像を保存するための変数
    var imageCache = NSCache<AnyObject, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(EmptyTableViewCell.self, forCellReuseIdentifier: emptyCellId)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    //検索ボタンが押されたときの処理
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //入力文字の有無をチェック
        guard let inputText = searchBar.text else {
            //入力文字なし
            return
        }
        
        //0文字よりも多かった場合
        guard inputText.lengthOfBytes(using: String.Encoding.utf8) > 0 else {
            //0文字よりも多くなかった場合
            return
        }
        
        //現時点で保持している本のデータを一旦全て削除
        bookDataArray.removeAll()
        
        let provider = MoyaProvider<GbaData>()
        provider.request(.search(request: ["q":"\(inputText)", "maxResults":"12"])) {
            result in
            switch result {
            //通信が成功したときの処理
            case let .success(moyaResponse):
                
                //decodeメソッドを呼び出す
                let jsonData = try? JSONDecoder().decode(TotalItems.self, from: moyaResponse.data)
                
                //※この「dump」は変数の中身を出力してくれる関数
                //dump(jsonData!)
                
                //オブジェクトの存在を確認してから商品のリストに追加
                for count in 0...11 {
                    if jsonData!.items![count].volumeInfo != nil {
                    self.bookDataArray.append(jsonData!.items![count].volumeInfo!)
                    } else {
                        print("要素が入っていないぜ")
                        break
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
            searchBar.resignFirstResponder()
        }
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemTableViewCell else {
            return UITableViewCell()
        }
        
        guard self.isBookListAvailable else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellId) as? EmptyTableViewCell {
                return cell
            }
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
