import SwiftUI

struct MenuItem {
    let id = UUID()
    let icon : Image
    let title : String
}

struct Menu {
    static let menuItems = [
        MenuItem(icon: Image(systemName: "car.fill"), title: "RDE"),
        MenuItem(icon: Image(systemName: "iphone.homebutton.radiowaves.left.and.right"), title: "Monitoring"),
        MenuItem(icon: Image(systemName: "square.fill.text.grid.1x2"), title: "Profiles"),
        MenuItem(icon: Image(systemName: "clock.arrow.circlepath"), title: "History"),
        MenuItem(icon: Image(systemName: "hand.raised.fill"), title: "Privacy"),
        MenuItem(icon: Image(systemName: "questionmark.circle.fill"), title: "Help")
    ]
}
