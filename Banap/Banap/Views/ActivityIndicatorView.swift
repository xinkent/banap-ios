import SwiftUI
import UIKit
struct ActivityIndicatorView: UIViewRepresentable {
   let style: UIActivityIndicatorView.Style
   let color: UIColor
   func makeUIView(context _: UIViewRepresentableContext<ActivityIndicatorView>) -> UIActivityIndicatorView {
       let indicatorView = UIActivityIndicatorView(style: style)
       indicatorView.color = color
       indicatorView.startAnimating()
       return indicatorView
   }
   func updateUIView(_ uiView: UIActivityIndicatorView, context _: UIViewRepresentableContext<ActivityIndicatorView>) {
//       isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
   }
}
