import SwiftUI
import Firebase
import MapKit
import CoreLocation
import Combine
import StoreKit
import GoogleMobileAds

struct UIMapView: View {
    // 現在位置の取得
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var storeObserver: StoreObserver
    @State var isFilter:Bool = false // Filteringフラグ
    @State var centerTappedNum:Int = 0 // 「現在地」がタップされた回数

    // 表示エリアの中心
    @State var centerCoordinate = CLLocationCoordinate2D(latitude:35.658577, longitude:139.745451)

    // タップされた店舗情報
    @State var isSelected: Bool  = false
    @State var selectedStore = Store()
    
    // フィルターボタンタップフラグ
    @State var isTapped: Bool = false
    
    // インタースティシャル広告
    @State var interstitial: GADInterstitial!
    
    // メインメッセージ表示フラグ
    @State var mainMessageIsShown = true
    

    // 表示地図の解像度
    let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)

    var body: some View {
        ZStack{
            // 地図表示
            MapView(isSelected: self.$isSelected, selectedStore: self.$selectedStore, centerCoordinate:self.$centerCoordinate, centerTappedNum: self.$centerTappedNum, isFilter: self.$isFilter)
                .edgesIgnoringSafeArea(.all)
                .statusBar(hidden: true)
                .sheet(isPresented: self.$isSelected){
                    StoreTapView(selectedStore: self.selectedStore)
                }
            .animation(.spring())
//                .onAppear(perform:self.setCenterRegion)
            VStack{
            Spacer().frame(maxHeight: .infinity)
            BannerView().frame(width: 320, height: 50)
            .padding(.bottom, 5)
            }
            
            // メッセージボックス
            if self.mainMessageIsShown{
                if self.storeObserver.mainMessage != nil{
                    VStack{
                        Spacer().frame(height:25)
                        HStack{
                            Spacer().frame(width:5)
                            Text(self.storeObserver.mainMessage!)
                            Spacer()
                            Button(action:{
                                withAnimation(.easeInOut(duration:10)){
                                    self.mainMessageIsShown.toggle()
                                }
                            }){
                                Image(systemName:"xmark.circle")
                            }
                            Spacer().frame(width:5)
                        }.frame(minWidth:0, maxWidth:.infinity)
                            .foregroundColor(.black)
                            .background(Color(red:1.0, green:1.0, blue:1.0, opacity:0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.yellow, lineWidth: 3))
                            .padding()
                        Spacer()
                    }
                }
            }
            
            // 現在位置ボタン
            
            VStack{
                Spacer().frame(height: 80)
                HStack{
                    Spacer().frame(width: 20)
                    // 現在位置移動ボタン
                    Button(action:{
                        self.setCenterRegion()
                        self.centerTappedNum += 1
                    }){
                        Image(systemName: "location")
                            .foregroundColor(.black)
                        .frame(width: 45, height: 45)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, lineWidth: 3))
                        Spacer()
                    }
                }
                Spacer()
            }
            
            // Filterボタン
            VStack(alignment: .leading){
                Spacer().frame(height: 130)
                HStack{
                    Spacer().frame(width: 20)
                    FilterView()
                        .onTapGesture{
                            self.isTapped.toggle()
                            if self.countTap() == 0{
                            if self.interstitial.isReady{
                            let root = UIApplication.shared.windows.first?.rootViewController
                            self.interstitial.present(fromRootViewController: root!)
                                                    }
                            }
                        }
                        .onAppear{
                            self.interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
                            let req = GADRequest()
                            self.interstitial.load(req)
                        }
                    Spacer()
//                        .frame(width: 350)
                }
                Spacer()
            }

            
            
            // Filter画面を表示
            ZStack{
                if self.isTapped == true{
                    VStack{
                        Spacer().frame(maxWidth: .infinity)
                            FilterSelectionView(isTapped: self.$isTapped, isFilter: self.$isFilter)
                            .padding(.bottom,65)
                    }
                }
            }
        }.onDisappear{self.isFilter = false}
    }

    func countTap() -> Int{
       var filterCount = UserDefaults.standard.value(forKey: "numOfTap") as? Int ?? 0
        filterCount = (filterCount + 1) % 3
        UserDefaults.standard.set(filterCount, forKey:"numOfTap")
        //10回タップごとにポップアップ表示
       return filterCount
   }

    func setCenterRegion(){
        if ["authorizedWhenInUse","authorizedAlways","restricted"].contains(self.locationManager.statusString)
        {
            // 値の更新を強制するため、乱数を加算
            let randomVal = 0.00000001 * Double.random(in: 1 ... 2)
            self.centerCoordinate = CLLocationCoordinate2D(latitude: (self.locationManager.lastLocation?.coordinate.latitude)! + randomVal, longitude: (self.locationManager.lastLocation?.coordinate.longitude)! + randomVal)
        }
    }
}

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    @EnvironmentObject var storeObserver:StoreObserver
    @EnvironmentObject var mapPosition:MapPosition // 現在の指定領域を記録しておく
    @Binding var isSelected: Bool // 店舗モーダルシート表示用
    @Binding var selectedStore: Store // 選択された店舗
    @Binding var centerCoordinate: CLLocationCoordinate2D // 「現在位置」タップ時の指定座標(変数名を変更したい)
    // 現在地機能用
    @Binding var centerTappedNum: Int // Viewの更新を受け取る
    static var centerTappedNum_inner:Int = 0 // 内部記録用


    // フィルタリング機能用
    @Binding var isFilter: Bool
    static var isFilter_inner:Bool = true
    
    let narrowSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)

    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        let view = MKMapView(frame: .zero)
        view.delegate = context.coordinator
        view.showsUserLocation = true
        
        view.setRegion(self.mapPosition.region, animated:true)
        
        // 内部変数の初期化
        MapView.self.isFilter_inner = true

        return view
    }

    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {

        // 中心を現在位置に移動
        print("updateUIView is called")
        // 記録されているタップ回数と異なる場合のみ作動
        if self.centerTappedNum != MapView.self.centerTappedNum_inner{
            print("Current Region Tapped")
            let region = MKCoordinateRegion(center: self.centerCoordinate, span: self.narrowSpan)
            uiView.setRegion(region, animated: true)
            MapView.self.centerTappedNum_inner = self.centerTappedNum
        }

        // Storeから情報を取得しピンを追加
        if self.isFilter != MapView.self.isFilter_inner{
            print("Annotations are replaced")
            uiView.removeAnnotations(uiView.annotations) // 現在のAnnotationを除去
            for store in self.storeObserver.stores{
                // フィルタリングされている場合は当日閉店している店舗を除く
                if !store.isOpenToday && self.isFilter{
                    continue
                }
                let annotation = CustomPointAnnotation()
                // annottationに情報を付加
                annotation.store = store
                annotation.coordinate = store.coordinate // ピンが刺される座標
                annotation.title = store.storeName // ピンに表示されるタイトル
                uiView.addAnnotation(annotation)
                
                // Annotationを更新できた場合のみ、内部変数を更新する
                MapView.self.isFilter_inner = self.isFilter
            }
        }
    }
    
    func makeCoordinator() -> MapView.Coordinator {
        return MapView.Coordinator(parent: self)
    }
}

extension MapView {
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent : MapView!
        init(parent: MapView){
            self.parent = parent
        }

        // annoattionタップ時のメソッド(現在は未設定)
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            
            // ユーザー現在位置タップ時はイベント発生させない
            if let annotationTitle = view.annotation!.title{
                if annotationTitle == "My Location"{
                    return
                }
            }
            
            if view.annotation is MKClusterAnnotation{
                return
            }
            
            // 店舗詳細画面遷移用のフラグをつける
            parent.isSelected = true
            print("isSelected IS changed to True")
            // カスタムAnnotationクラスにキャスト
            guard let customSelectedAnnotation = view.annotation as? CustomPointAnnotation
                else{
                    return
            }
            parent.selectedStore = customSelectedAnnotation.store
            
            // Appレビューのポップアップ表示
            var numOfTapped = UserDefaults.standard.value(forKey: "numOfTapp") as? Int ?? 0
            numOfTapped = (numOfTapped + 1) % 10
            UserDefaults.standard.set(numOfTapped, forKey:"numOfTapp")
            //10回タップごとにポップアップ表示
           if numOfTapped == 0{
                SKStoreReviewController.requestReview()
           }
        }
       //アノテーションビューを返すメソッド
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            let reuseId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
                pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                //ピンの色を黄色に変更
                pinView?.markerTintColor = UIColor.systemYellow
                //ピンのイメージをバナナ画像に変更（BananaのB）
                pinView?.glyphImage = UIImage(named:"LaunchImage")
                pinView?.displayPriority = .required
                pinView?.clusteringIdentifier = "identifier"
                pinView?.collisionMode = .circle
            return pinView
        }
        
        // 可視領域変更時のメソッド
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            // 現在の可視領域を保存する
            parent.mapPosition.region = mapView.region
        }
    }

// アノテーションに店舗IDを付与するため、カスタムアノテーションクラスを作成
class CustomPointAnnotation: MKPointAnnotation {
    var store = Store()
}
}
