
import Foundation
import MapKit

struct Store: Identifiable{
    var id = String()
    var storeName = String()
    var coordinate = CLLocationCoordinate2D()
    var storeAddress = String()
    var storeHours = String()
    var storeClose = String()
    var storeWebsite = String()
    var storeScore = Double()
    var addDate = Date()
    var isOpenToday: Bool{
        if self.storeClose == "-"{
            return false
        }
        let date = Date()
        return !self.storeClose.contains(date.weekday)
    }
}

// Checkedの時と同じ、本日の日付を取得するえ拡張機能
extension Date {
    var weekday: String {
        let calendar = Calendar(identifier: .gregorian)
        let component = calendar.component(.weekday, from: self)
        let weekday = component - 1
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja")
        return formatter.shortWeekdaySymbols[weekday] //短い曜日（月火水木金）を返す
    }
}


struct Review: Identifiable{
    var id: Int
    var comment: String
    var score: Int
}
