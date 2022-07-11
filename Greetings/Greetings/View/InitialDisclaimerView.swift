import SwiftUI

struct InitialDisclaimerView: View {
    var body: some View {
        VStack{
            BaseWebView(title: "disclaimer")
            HStack{
                Spacer()
                NavigationLink(destination: InitialPrivacyView(), label: {
                    Text("I AGREE AND CONTINUE")
                })
                .padding()
            }
            .background(Color.black)
            .foregroundColor(.white)
        }
    }
}
