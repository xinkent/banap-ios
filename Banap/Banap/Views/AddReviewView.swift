import SwiftUI
import Firebase

struct AddReviewView: View {
    @State var review_text = ""
    @State var rating: Int = 3
    @State var toSend = false // 送信前確認用Alertの表示フラグ
    @State var isSend = false // 送信後確認用Alertの表示フラグ
    @State var isError = false // 送信失敗用Alertの表示フラグ
    @State var validMsg = "" // エラーメッセージ
    @Environment(\.presentationMode) var presentation // 前の画面に遷移するための環境変数
    var store: Store
    
    
    var body: some View {
        VStack{
            Form{
                Section(header: Text("店名").font(.headline)){
                    Text("\(self.store.storeName)")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                }
                Section(header: Text("レビュー").font(.headline)){
                    VStack{
                        MultiLineTF(txt: self.$review_text)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight:150, maxHeight:300)
                    }
                    RatingView(rating:$rating)
                        .frame(maxWidth: .infinity, maxHeight: 20)
                }
                HStack{
                    Spacer()
                    Button(action:{
                        self.toSend = true
                    }){
                        Text("送信")
                    }
                    Spacer()
                }
            }
        
            Spacer()
                .frame(height:0)
                .alert(isPresented: $toSend) {// 送信確認メッセージ
                Alert(
                    title: Text("送信しますか?"),
                    primaryButton: .default(Text("Yes"),
                    action: {
                        self.send_review()
                    }),
                    secondaryButton: .cancel(Text("cancel")))
            }
            Spacer()
                .frame(height:0)
                .alert(isPresented: $isSend) {// 送信成功メッセージ
                Alert(
                     title: Text("レビューが送信されました！"),
                      dismissButton: .default(Text("OK"),
                      action:{self.clear()} //初期状態に戻す
                    )
                )
            }
            Spacer()
                .frame(height:0)
                .alert(isPresented: $isError) {// 送信失敗メッセージ
                Alert(title: Text("エラー"),
                      message: Text(self.validMsg),
                      dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    func send_review(){
        let now = Date() // 現在時刻を取得
        let uid = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        db.collection("bananaStores").document(self.store.id).collection("Reviews").document(uid!).setData(
            [
            "comment":self.review_text,
            "score":self.rating,
            "reviewDate": now
            ]
        ){err in
            if let err = err {
                print("Error adding document \(err)")
                self.validMsg = "送信できませんでした。"
                self.isError = true
            } else {
                self.isSend = true
                return
            }
        }
    }
    
    func clear(){
        self.review_text = ""
        self.rating = 3
        self.presentation.wrappedValue.dismiss() // 前の画面に遷移
    }
}


// 複数業入力用のテキストフィールド
struct MultiLineTF : UIViewRepresentable{
    func makeCoordinator() -> Coordinator {
        return MultiLineTF.Coordinator(parent1: self)
    }
    
    @Binding var txt: String
    
    func makeUIView(context: UIViewRepresentableContext<MultiLineTF>) -> UITextView {
        let  tview = UITextView()
        tview.isEditable = true
        tview.isUserInteractionEnabled = true
        tview.isScrollEnabled = true
        tview.text = "レビューを書いてみよう！"
        tview.textColor  = .gray
        tview.delegate = context.coordinator
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: tview.frame.size.width, height: 44))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(tview.doneButtonTapped(button:)))
        toolBar.items = [doneButton]
        toolBar.setItems([doneButton], animated: true)
        tview.inputAccessoryView = toolBar
        
        return tview
    }
    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<MultiLineTF>) {
    }
    
    class Coordinator: NSObject, UITextViewDelegate{
        var parent: MultiLineTF
        
        init(parent1: MultiLineTF){
            parent = parent1
        }
        
        func textViewDidChange(_ textView: UITextView){
            self.parent.txt = textView.text
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.text = ""
            textView.textColor = .label
        }
    }
        
}

extension  UITextView{
    @objc func doneButtonTapped(button:UIBarButtonItem) -> Void {
       self.resignFirstResponder()
    }
}

