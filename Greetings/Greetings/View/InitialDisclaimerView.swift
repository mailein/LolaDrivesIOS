import SwiftUI

struct InitialDisclaimerView: View {
    @Binding var isDisclaimerPresenting: Bool
    @Binding var isPrivacyPresenting: Bool
    
    var body: some View {
        VStack{
            BaseWebView(title: "disclaimer")
            HStack{
                Spacer()
                Button(action: {
                    isPrivacyPresenting = true
                }, label: {
                    Text("I AGREE AND CONTINUE")
                        .padding()
                })
            }
            .background(Color.black)
            .foregroundColor(.white)
        }
        .fullScreenCover(isPresented: $isPrivacyPresenting) {
            InitialPrivacyView(isDisclaimerPresenting: $isDisclaimerPresenting, isPrivacyPresenting: $isPrivacyPresenting)
        }
    }
}
