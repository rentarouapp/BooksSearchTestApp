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
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var authors: [String] = []
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
        realmBookData.authors = bookItem.volumeInfo?.authors ?? []
        realmBookData.smallImageUrl = bookItem.volumeInfo?.imageLinks?.smallThumbnail ?? ""
        realmBookData.largeImageUrl = bookItem.volumeInfo?.imageLinks?.thumbnail ?? ""
        realmBookData.infoUrl = bookItem.volumeInfo?.infoLink ?? ""
        realmBookData.publishedDate = bookItem.volumeInfo?.publishedDate ?? ""
        realmBookData.textDescription = bookItem.volumeInfo?.description ?? ""
        return realmBookData
    }
    
    // データの書き込み
    static func writeData(bookItem: BookItem) {
        guard let realm = RealmManager.getRealm() else { return }
        let realmBookData = RealmManager.getRealmBookDataObjct(bookItem: bookItem)
        do {
            try realm.write {
                realm.add(realmBookData)
            }
        } catch {
            // ダイアログ表示
            print(error.localizedDescription)
        }
    }
    
    // データの削除
    static func deleteData(id: String) {
        guard let realm = RealmManager.getRealm() else { return }
        let targetBookData = realm.objects(RealmBookData.self).filter("id == \(id)")
        do {
            try realm.write {
                realm.delete(targetBookData)
            }
        } catch {
            // ダイアログ表示
            print(error.localizedDescription)
        }
    }
    
    // データ取得
    static func getRealmBookData() -> [BookItem]? {
        guard let realm = RealmManager.getRealm() else { return nil }
        var bookItems: [BookItem] = []
        let results = realm.objects(RealmBookData.self)
        results.forEach {
            let imageLink = ImageLinks(thumbnail: $0.largeImageUrl, smallThumbnail: $0.smallImageUrl)
            let volumeInfo = VolumeInfo(title: $0.title, authors: $0.authors, imageLinks: imageLink, infoLink: $0.infoUrl, publishedDate: $0.publishedDate, description: $0.textDescription)
            let bookItem: BookItem = BookItem(id: $0.id, volumeInfo: volumeInfo)
            bookItems.append(bookItem)
        }
        return bookItems
    }
}

