import SwiftUI
import Firebase

struct StoreTapView: View {
    @State var storeImage:UIImage?
    var selectedStore: Store
    
    // 店舗画像が用意されていない場合のデフォルト画像
    let placeholder = UIImage(named:"BananaNoImage")!
    
    var body: some View {
        VStack{
            // Spacer().frame(height: 100)
            NavigationView{
                StoreDetailView(storeImage: $storeImage, selectedStore: self.selectedStore)
                .navigationBarTitle("店舗情報")
            }
        }.onAppear(perform: self.getStoreImage)
    }
    
    // FireStorageから、タップされた店舗IDの店舗画像をロード
    func getStoreImage(){
        let storage = Storage.storage()
        let reference = storage.reference(withPath: "/Banap/storeImages/\(self.selectedStore.id).png")
        print("Banap/storeImages/\(self.selectedStore.id).png")
        reference.getData(maxSize: 5 * 1024 * 1024){data, error in
            guard error == nil else{
                print("No store Image")
                print(error!.localizedDescription)
                return
            }
            self.storeImage = UIImage(data: data!)!
        }
    }
}


//struct StoreTapView_Previews: PreviewProvider {
//    static var previews: some View {
//        StoreTapView()
//    }
//}
