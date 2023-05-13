//
//  RealmManager.swift
//  BookSearchMoyaMap
//
//  Created by 上條蓮太朗 on 2023/05/11.
//  Copyright © 2023 uejo. All rights reserved.
//

import Foundation
import RealmSwift

class RealmBookData: Object {
    @objc dynamic var bookId: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var authors: String = ""
    @objc dynamic var smallImageUrl: String = ""
    @objc dynamic var largeImageUrl: String = ""
    @objc dynamic var infoUrl: String = ""
    @objc dynamic var publishedDate: String = ""
    @objc dynamic var textDescription: String = ""
    // プライマリキー
    override static func primaryKey() -> String? {
        return "bookId"
    }
}

class RealmManager {
    
    static let shared = RealmManager()
    private init() {
        do {
            self.realm = try Realm()
        } catch let error as NSError {
            print(error)
        }
    }
    
    private var realm :Realm?
    
    private func getRealmBookDataObjct(bookItem: BookItem) -> RealmBookData {
        let realmBookData = RealmBookData()
        realmBookData.bookId = bookItem.id ?? ""
        realmBookData.title = bookItem.volumeInfo?.title ?? ""
        let authors = bookItem.volumeInfo?.authors?.joined(separator: ",")
        realmBookData.authors = authors ?? ""
        realmBookData.smallImageUrl = bookItem.volumeInfo?.imageLinks?.smallThumbnail ?? ""
        realmBookData.largeImageUrl = bookItem.volumeInfo?.imageLinks?.thumbnail ?? ""
        realmBookData.infoUrl = bookItem.volumeInfo?.infoLink ?? ""
        realmBookData.publishedDate = bookItem.volumeInfo?.publishedDate ?? ""
        realmBookData.textDescription = bookItem.volumeInfo?.description ?? ""
        return realmBookData
    }
    
    // データの書き込み
    func writeBookData(bookItem: BookItem, completion: @escaping (Error?) -> Void) {
        guard let realm = self.realm else { return }
        do {
            try realm.write {
                let realmBookData = self.getRealmBookDataObjct(bookItem: bookItem)
                realm.add(realmBookData, update: .modified)
                completion(nil)
            }
        } catch {
            // ダイアログ表示
            completion(error)
        }
    }
    
    // データの削除
    func deleteBookData(id: String, completion: @escaping (Error?) -> Void) {
        guard let realm = self.realm else { return }
        let targetBookData = realm.objects(RealmBookData.self).filter("id == \(id)")
        do {
            try realm.write {
                realm.delete(targetBookData)
                completion(nil)
            }
        } catch {
            // ダイアログ表示
            completion(error)
        }
    }
    
    // idに紐づくデータあるか判定
    func isAvailableRealmBookDataFromId(id: String) -> Bool {
        guard let realm = self.realm else { return false }
        let targetBookDatas = realm.objects(RealmBookData.self).where({ $0.bookId == id })
        return !targetBookDatas.isEmpty
    }
    
    // データ全件取得
    func getRealmAllBookData() -> [BookItem] {
        guard let realm = self.realm else { return [] }
        var bookItems: [BookItem] = []
        let results = realm.objects(RealmBookData.self)
        results.forEach {
            let imageLink = ImageLinks(thumbnail: $0.largeImageUrl, smallThumbnail: $0.smallImageUrl)
            let volumeInfo = VolumeInfo(title: $0.title, authors: $0.authors.components(separatedBy: ","), imageLinks: imageLink, infoLink: $0.infoUrl, publishedDate: $0.publishedDate, description: $0.textDescription)
            let bookItem: BookItem = BookItem(id: $0.bookId, volumeInfo: volumeInfo)
            bookItems.append(bookItem)
        }
        return bookItems
    }
}

