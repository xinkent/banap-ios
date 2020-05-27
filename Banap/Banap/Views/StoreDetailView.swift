import SwiftUI

struct StoreDetailView: View {
    @Binding var storeImage:UIImage?
    var selectedStore: Store

    // 店舗画像が用意されていない場合のデフォルト画像
    let placeholder = UIImage(named:"BananaNoImage")!

    var body: some View {
        ScrollView{
            VStack{
                // 店舗画像
                Image(uiImage: self.storeImage ?? placeholder)
                    .resizable()
                    .frame(width: 250, height: 250)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.yellow, lineWidth: 4))
                    .shadow(radius: 10)
                Spacer().frame(height: 50)
                // 店舗名
                Text("\(self.selectedStore.storeName)")
                .font(.system(size: 24))
                // 店舗スコア
                HStack{
                    FixedRatingView(rating: Int(self.selectedStore.storeScore))
                    Text(String(format: "%.1f", self.selectedStore.storeScore))
                    .font(.system(size: 22))
                }
            }
            VStack(alignment: .leading){
                Group{
                    // 店舗情報
                    HStack{
                        Image(systemName: "mappin.and.ellipse")
                        Text("\(self.selectedStore.storeAddress)")
                    }
                    .padding(.horizontal, 15)
                    HStack{
                        Image(systemName: "paperclip")
                        Button(action:{
                            self.openWebBrowser()
                        }){
                            Text("\(self.selectedStore.storeWebsite)")
                        }
                    }
                    .padding(.horizontal, 15)
                    HStack{
                        Image(systemName: "clock")
                        Text("\(self.selectedStore.storeHours)")
                    }
                    .padding(.horizontal, 15)
                    HStack{
                        Image(systemName: "moon.zzz")
                        Text("\(self.selectedStore.storeClose)")
                    }
                    .padding(.horizontal, 15)
                    Spacer().frame(height: 30)
                    Text("※営業時間・定休日は変更となる場合がございます。")
                    .font(.caption)
                    .fontWeight(.thin)
                    .padding(.horizontal, 15)
                    Text("ご来店前に店舗にご確認ください。")
                    .font(.caption)
                    .fontWeight(.thin)
                    .padding(.horizontal, 15)
                    Spacer().frame(height: 10)
                    Text("※イメージに関する著作権、および掲載情報に係る権利は")
                    .font(.caption)
                    .fontWeight(.thin)
                    .padding(.horizontal, 15)
                    Text("店舗に帰属します。")
                    .font(.caption)
                    .fontWeight(.thin)
                    .padding(.horizontal, 15)
                }
                Spacer().frame(height:30)
                // レビュー表示
                VStack{
                    ReviewListView(storeID: self.selectedStore.id)
                }.padding(.horizontal, 15)
                
            }
            
            
        }.navigationBarItems(trailing:
        NavigationLink(destination: AddReviewView(store:self.selectedStore).navigationBarTitle("レビュー投稿")
        ){
                Text("レビュー投稿")
        }
        )
    }

    // webリンク遷移用
    func openWebBrowser() {
        let url = URL(string: "\(selectedStore.storeWebsite)")!
        // 一度本当にURLが開けるか確認する
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
