import SwiftUI

struct ProfileEditView: View{
    @EnvironmentObject var model: Model
    @Binding var profile: Profile
    
    var body: some View{
        ScrollView{
            VStack{
                HStack{
                    Text("Name: ")
                    TextField("Profile Name", text: $profile.name)
                        .textFieldStyle(.roundedBorder)
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                        }
                }
                Text("Select the commands that you want to be tracked")
                    .foregroundColor(.gray)
                    .font(.caption)

                ForEach(profile.commands.indexed(), id: \.1.id) { index, commandItem in
                    VStack{
                        Toggle(isOn: $profile.commands[index].enabled){
                            Text(commandItem.name)
                        }
                        Spacer()
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear{
                model.editProfileData(to: profile) //TextField.onSubmit only works if user taps return in keyboard, Toggle.onSubmit doesn't respond either. so how to capture the new values? update onDisappear is a workaround
            }
        }
    }
}

//struct EditProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileEditView(profile: Profile("default_profile", enabled: ["RPM", "SPEED"]))
//    }
//}
