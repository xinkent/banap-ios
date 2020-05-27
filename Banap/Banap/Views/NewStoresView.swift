import SwiftUI
import Firebase

struct NewStoresView: View {
    @EnvironmentObject var storeObserver:StoreObserver
    
    var body: some View {
        ZStack{
            NavigationView{
                Group{
                    if !self.storeObserver.stores.isEmpty{
                        List{
                            // addDateが新しい順に15店舗表示
                            ForEach(self.storeObserver.stores.sorted(by:{$0.addDate > $1.addDate})[0 ..< 15]){store in
                                VStack(alignment:.leading){
                                    NewStoreRowView(store: store)
                                    Text("\(self.dateToString(date:store.addDate))に追加")
                                        .font(.caption)
                                        .fontWeight(.thin)
                                }
                            }
                        }
                    } else {
                        Text("Loading...")
                    }
                }
                .navigationBarTitle("新着店舗")
            }
            .padding(.top, 30)
            .navigationViewStyle(StackNavigationViewStyle())
            
            VStack{
                Spacer().frame(maxHeight: .infinity)
                BannerView().frame(width: 320, height: 50)
                    .padding(.bottom, 5)
            }
        }
    }
    
    func dateToString(date:Date) -> String{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

// List内の各店舗のView
struct NewStoreRowView: View{
    var store:Store
    @State var storeImage: UIImage?
    let placeholder = UIImage(named:"BananaNoImage")!

    var body: some View{
        NavigationLink(
            destination: StoreDetailView(storeImage: $storeImage, selectedStore: self.store)
        ){
            HStack{
                Image(uiImage: self.storeImage ?? placeholder)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.yellow, lineWidth: 1))
                Text("\(store.storeName)")
            }
        }.onAppear(perform:self.getStoreImage)
    }

    func getStoreImage(){
        let storage = Storage.storage()
        let reference = storage.reference(withPath: "/Banap/storeImages/\(self.store.id).png")
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
