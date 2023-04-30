//
//  WebViewController.swift
//  BookSearchMoyaMap
//
//  Created by uejo on 2020/05/08.
//  Copyright © 2020 uejo. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var bookUrl: String?
    
    @IBOutlet weak var bookWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //User-AgentをiPhoneに設定
        bookWebView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0_1 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Geoko) Version/11.0 Mobile/15A402 Safari/604.1"
        
        //URLを読み込ませてWebページを表示させる
        //bookUrlのnilチェック
        guard let bookUrl = bookUrl else {
            return
        }
        
        //urlを設定
        guard let url = URL(string: bookUrl) else {
            return
        }
        
        //リクエストを生成
        let request = URLRequest(url: url)
        bookWebView.load(request)

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
