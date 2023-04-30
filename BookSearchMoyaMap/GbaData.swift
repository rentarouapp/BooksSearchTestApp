//
//  GbaData.swift
//  BookSearchMoyaMap
//
//  Created by uejo on 2020/05/08.
//  Copyright © 2020 uejo. All rights reserved.
//

import Foundation
import Moya

enum GbaData {
    case search(request: Dictionary<String, Any>)
}

extension GbaData: TargetType {
    //呼び出すAPIのURLを書く
    var baseURL: URL {
        return URL(string: "https://www.googleapis.com/books/v1")!
    }
    
    //APIのpathを書く
    var path: String {
        switch self {
        case .search:
            return "/volumes"
        }
    }
    //apiのメソッドを書く（getなのかpostなのか）
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    //apiでなにを送りたいのかを書く（パラメータのこと）
    var task: Task {
        switch self {
        case .search(let request):
            return .requestParameters(parameters: request, encoding: URLEncoding.default)
        }
    }
    
    //リクエストヘッダの設定
    var headers: [String : String]? {
        return ["components-type":"application/json"]
    }
}
