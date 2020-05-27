// 位置情報取得のためのクラス
import Foundation
import CoreLocation
import Combine
import Firebase
import MapKit

/*------------------------------------------------------
現在位置取得用のクラス
------------------------------------------------------*/
class LocationManager: NSObject, ObservableObject {

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var lastLocation: CLLocation? {
        willSet {
            objectWillChange.send()
        }
    }

    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }

        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }

    }

    let objectWillChange = PassthroughSubject<Void, Never>()

    private let locationManager = CLLocationManager()
}

// 位置情報変化時のデリゲーションメソッドを設定
extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
        print(#function, statusString)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        print(#function, location)
    }

}

/*------------------------------------------------------
Firestoreデータベースのリスナー
------------------------------------------------------*/
class StoreObserver: ObservableObject {
    // 店舗情報
    @Published var stores:[Store] = []
    // メインメッセージ
    @Published var mainMessage:String?;
    
    let defaultScore:Double = 3.0 // レビューがない場合のデフォルト点数
    
    func listenStoreData(){
        // ユーザー情報を取得
        var user = Auth.auth().currentUser
        // 認証済みの場合は、addListnerを実行
        if user != nil {
            self.addListner()
            self.addMessageListner()
            return
        }
        // 認証済みでない場合は、認証が確認できるまで非同期でlisten処理を継続する。
        DispatchQueue.global().async {
            while user == nil{
                user = Auth.auth().currentUser;
                self.addListner()
                self.addMessageListner()
                print("listen")
                Thread.sleep(forTimeInterval: 1)
            }
        }
    }
    
    func addListner(){
        let db = Firestore.firestore()
        db.collection("bananaStores").addSnapshotListener{ querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            for doc in documents{
                let dataDescription = doc.data()
                print("dataDescription => \(dataDescription)")
                // ドキュメントIDを取得
                let docID = doc.documentID
                // 店舗名、位置情報を取得
                guard let storeName = dataDescription["storeName"] as? String,
                      let latitude = dataDescription["latitude"] as? Double,
                      let longitude = dataDescription["longitude"] as? Double
                else{
                    print("Data format is wrrong")
                    continue
                }
                let coordnate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let storeAddress = dataDescription["storeAddress"] as? String ?? "-"
                let storeHours = dataDescription["storeHours"] as? String ?? "-"
                let storeClose = dataDescription["storeClose"] as? String ?? "-"
                let storeWebsite = dataDescription["storeWebsite"] as? String ?? "-"
                let storeScore = dataDescription["avgScore"] as? Double ?? self.defaultScore
                let addDateTemp = dataDescription["addDate"] as? Timestamp
                var addDate = Date()
                // 登録日がデータにない場合はデフォルトの日付を設定する
                if addDateTemp != nil{
                    addDate = addDateTemp!.dateValue()
                }else{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/MM/dd HH:mm"
                    let defaultDateTime = formatter.date(from: "2020/01/01 00:00")
                    addDate = defaultDateTime!
                }
                
                let store = Store(id: docID, storeName: storeName, coordinate: coordnate, storeAddress: storeAddress, storeHours: storeHours, storeClose: storeClose, storeWebsite: storeWebsite, storeScore: storeScore, addDate: addDate)


                if !(self.stores.map{store in store.id}).contains(docID){
                    self.stores.append(store)
                }
            }
        }
    }
    
    func addMessageListner(){
        let db = Firestore.firestore()
        db.collection("Message").document("mainMessage").addSnapshotListener{ documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            print("Messagedata: \(data)")
            self.mainMessage = data["text"] as? String
         }
    }
}

/*------------------------------------------------------
mapViewの表示位置保持用のクラス
------------------------------------------------------*/
class MapPosition: ObservableObject {
    var region:MKCoordinateRegion
    init(){
        let coordinate = CLLocationCoordinate2D(latitude:35.658577, longitude:139.745451)
        let span = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        self.region = MKCoordinateRegion(center: coordinate, span: span)
    }
}
