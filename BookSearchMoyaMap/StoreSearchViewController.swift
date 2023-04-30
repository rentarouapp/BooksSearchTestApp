//
//  StoreSearchViewController.swift
//  BookSearchMoyaMap
//
//  Created by uejo on 2020/05/08.
//  Copyright © 2020 uejo. All rights reserved.
//

import UIKit
import CoreLocation

class StoreSearchViewController: UIViewController {
    
    //フィールド変数としてロケーションマネジャーを定義
    var locationManager: CLLocationManager!
    
    //緯度と経度を格納するフィールド変数を定義
    //緯度
    var longitudeNow: String = ""
    //経度
    var latitudeNow: String = ""
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()

        // Do any additional setup after loading the view.
    }
    
    //位置情報取得開始ボタンを押下
    @IBAction func goButton(_ sender: Any) {
        //ステータスを定義
        let status = CLLocationManager.authorizationStatus()
        //位置情報の承認がはねられているとき
        if status == .denied {
            showAlert()
            print("はねられているよ")
        } else if status == .authorizedWhenInUse {
            
            //委譲先を自分自身に設定
            locationManager.delegate = self
            //位置情報の取得を開始※これが抜けていたのかも
            locationManager.startUpdatingLocation()
            
            self.longitudeLabel.text = longitudeNow
            self.latitudeLabel.text = latitudeNow
            
            print(self.longitudeLabel.text!)
            print(self.latitudeLabel.text!)
        }
    }
    
    //クリアボタンを押下
    @IBAction func clearButton(_ sender: Any) {
        self.longitudeLabel.text = "緯度：デフォルト"
        self.latitudeLabel.text = "経度：デフォルト"
    }
    
    @IBAction func nextButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toStoreList", sender: nil)
    }
    
    func setupLocationManager() {
        //ロケーションマネジャーのセットアップ
        locationManager = CLLocationManager()
        
        CLLocationManager.locationServicesEnabled()
        
        //位置情報ダイアログの表示
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        
        //マネジャーの設定
        let status = CLLocationManager.authorizationStatus()
        //ステータスごとの処理
        //もしアプリ使うときだけ許可されていたら
        if status == .authorizedWhenInUse {
            locationManager.delegate = self
            //位置情報取得を開始する
            locationManager.startUpdatingLocation()
        }
        
    }
    
    //アラートを表示するための関数
    func showAlert() {
        //位置情報が許可されなかったときのアラート
        let alertTitle = "位置情報が許可されていません"
        let alertMessage = "「設定」アプリの「プライバシー > 位置情報サービス」から変更してください"
        
        //アラートを生成
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        
        //OKボタンを生成
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        
        //UIAleartControllerにActionを追加
        alert.addAction(defaultAction)
        
        //Alertを表示
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toStoreList" {
            let nextView = segue.destination as!
            StoreTableViewController
            
            //緯度をダブル型に変換
            let longitudeDouble = atof(self.longitudeNow)
            //経度をダブル型に変換
            let latitudeDouble = atof(self.latitudeNow)
            
            //緯度を次の画面に渡す
            nextView.longitude = longitudeDouble
            //経度を次の画面に渡す
            nextView.latitude = latitudeDouble
        }
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

extension StoreSearchViewController: CLLocationManagerDelegate {

//位置情報が更新されたときに位置情報を格納する
//manager: ロケーションマネジャー
//location: 位置情報
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //位置情報を取得する度に位置情報を格納する用のフィールド
        let location = locations.first
        
        let longitude = location?.coordinate.longitude
        
        let latitude = location?.coordinate.latitude
        
        //位置情報を格納する
        self.longitudeNow = String(longitude!)
        self.latitudeNow = String(latitude!)
        
    }


}
