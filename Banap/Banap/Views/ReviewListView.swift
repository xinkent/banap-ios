import SwiftUI
import Firebase

struct ReviewListView: View {
    var storeID:String
    @State var reviews:[Review] = []
    @State var reviewDisplayNum:Int = 3 // レビュー初期表示数
    
    var body: some View {
        VStack(alignment:.leading){
            HStack{
                Text("\(self.reviews.count)件のレビュー")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                Spacer()
                Button(action:{
                    self.reviewDisplayNum = 100
                }){
                    Text("レビューを全て表示")
                }
            }
            Divider().background(Color(red:1.0, green: 1.0, blue: 0.8))
            ForEach(self.reviews[0..<(min(self.reviewDisplayNum, self.reviews.count))]){ review in
                VStack{
                    HStack{
                        VStack(alignment: .leading){
                            HStack{
                                FixedRatingView(rating:review.score)
                                Text("\(review.score)")
                                Spacer()
                            }
                            HStack{
                                Text(review.comment)
                                    .frame(minHeight:20, maxHeight: .infinity)
                                    .lineLimit(nil)
                                Spacer()
                            }
                        }
                        
                    }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    Divider().background(Color(red:1.0, green: 1.0, blue: 0.8))
                }
            }
        }
        .onAppear(perform:self.getReviews)
    }
    
    func getReviews(){
        let db = Firestore.firestore()
        db.collection("bananaStores").document(self.storeID).collection("Reviews").getDocuments(){(querySnapshot, err) in
            if let err = err{
                print("Error getting documents: \(err)")
            } else {
                for (i, document) in querySnapshot!.documents.enumerated() {
                    let dataDescription = document.data()
                    print("get Review \(dataDescription)")
                    let comment = dataDescription["comment"] as? String ?? "-"
                    let removedComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
                    let score = dataDescription["score"] as? Int ?? 0
                    self.reviews.append(Review(id:i, comment: removedComment, score: score))
                    print("Review Comment: \(comment)")
                    print("Review Comment Removed: \(removedComment)")
                }
            }
        }
        
    }
}
