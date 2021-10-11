import SwiftUI

struct ProfilesView: View {
    var body: some View {
        VStack{
            HStack{
                Text("Select your tracking profile from the list below")
                NavigationLink(destination: EditProfileView(), label: {
                    Image(systemName: "plus.app.fill")
                })
            }
            Spacer()
        }
    }
}

struct EditProfileView: View{
    var body: some View{
        Text("Profile Name")
    }
}

struct ProfilesView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilesView()
    }
}
