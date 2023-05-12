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
    var authors = List<String>()
    @objc dynamic var smallImageUrl: String = ""
    @objc dynamic var largeImageUrl: String = ""
    @objc dynamic var infoUrl: String = ""
    @objc dynamic var publishedDate: String = ""
    @objc dynamic var textDescription: String = ""
}

class RealmManager {
    
    static func getRealm() -> Realm? {
        do {
            let realm = try Realm()
            return realm
        } catch {
            return nil
        }
    }
    
    static func getRealmBookDataObjct(bookItem: BookItem) -> RealmBookData {
        let realmBookData = RealmBookData()
        realmBookData.title = bookItem.volumeInfo?.title ?? ""
        let arrayAuthors = bookItem.volumeInfo?.authors ?? []
        arrayAuthors.forEach {
            realmBookData.authors.append($0)
        }
        realmBookData.smallImageUrl = bookItem.volumeInfo?.imageLinks?.smallThumbnail ?? ""
        realmBookData.largeImageUrl = bookItem.volumeInfo?.imageLinks?.thumbnail ?? ""
        realmBookData.infoUrl = bookItem.volumeInfo?.infoLink ?? ""
        realmBookData.publishedDate = bookItem.volumeInfo?.publishedDate ?? ""
        realmBookData.textDescription = bookItem.volumeInfo?.description ?? ""
        return realmBookData
    }
    
    // データの書き込み
    static func writeBookData(bookItem: BookItem, completion: @escaping (Error?) -> Void) {
        guard let realm = RealmManager.getRealm() else { return }
        let realmBookData = RealmManager.getRealmBookDataObjct(bookItem: bookItem)
        do {
            try realm.write {
                realm.add(realmBookData)
                completion(nil)
            }
        } catch {
            // ダイアログ表示
            completion(error)
        }
    }
    
    // データの削除
    static func deleteBookData(id: String, completion: @escaping (Error?) -> Void) {
        guard let realm = RealmManager.getRealm() else { return }
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
    static func isAvailableRealmBookDataFromId(id: String) -> Bool {
        guard let realm = RealmManager.getRealm() else { return false }
        let targetBookDatas = realm.objects(RealmBookData.self).filter("bookId == \(id)")
        return !targetBookDatas.isEmpty
    }
    
    // データ全件取得
    static func getRealmAllBookData() -> [BookItem] {
        guard let realm = RealmManager.getRealm() else { return [] }
        var bookItems: [BookItem] = []
        let results = realm.objects(RealmBookData.self)
        results.forEach {
            let imageLink = ImageLinks(thumbnail: $0.largeImageUrl, smallThumbnail: $0.smallImageUrl)
            let volumeInfo = VolumeInfo(title: $0.title, authors: Array($0.authors), imageLinks: imageLink, infoLink: $0.infoUrl, publishedDate: $0.publishedDate, description: $0.textDescription)
            let bookItem: BookItem = BookItem(id: $0.bookId, volumeInfo: volumeInfo)
            bookItems.append(bookItem)
        }
        return bookItems
    }
}

