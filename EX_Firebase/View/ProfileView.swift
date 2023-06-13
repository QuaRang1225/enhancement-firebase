//
//  ProfileView.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/13.
//

import SwiftUI

@MainActor
final class ProfileViewModel:ObservableObject{
    

    @Published var user:UserDataBase? = nil
    
    func loadCurrentUser() async throws{
        let authUser = try AuthenticationManager.shared.getUser()
        user = try await UserManager.shared.getUser(userId: authUser.uid)
    }
    
    func togglePremium(){
        guard let user  else {return}
        let currnetValue = user.isPremium ?? false
        Task{
            try await UserManager.shared.updateUserPreminumStatus(userId: user.userId, isPremium: !currnetValue)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addUserPreference(text:String){
        guard let user  else {return}
        
        Task{
            try await UserManager.shared.addUserPreference(userId:user.userId,preference:text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    func deleteUserPreference(text:String){
        guard let user  else {return}
        
        Task{
            try await UserManager.shared.deleteUserPreference(userId:user.userId,preference:text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    func favoriteMovie(){
        guard let user  else {return}
        let movie = Movie(id: "1", title: "빔죄도시", isPopular: true)
        Task{
            try await UserManager.shared.favoriteMovie(userId:user.userId,movie:movie)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    func deleteFavoriteMovie(){
        guard let user  else {return}
        Task{
            try await UserManager.shared.deleteFavoriteMovie(userId:user.userId)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
}

struct ProfileView: View {
    
    let option:[String]=["스포츠","영화","책"]
    @StateObject var vm = ProfileViewModel()
    @Binding var showSignView:Bool
    
    private func preference(text:String)->Bool{
        vm.user?.preference?.contains(text) == true
    }
    var body: some View {
        List{
            if let user = vm.user{
                Text("아이디 : \(user.userId )")
                if let email = user.email{
                    Text("이메일 : \(email)")
                }
                if let date = user.dateCreated{
                    Text("계정 생성일자 : \(date)")
                }
                Button {
                    vm.togglePremium()
                } label: {
                    Text("프리미얼 : \((user.isPremium ?? false).description.capitalized)")
                }
                VStack{
                    HStack{
                        ForEach(option,id:\.self) { item in
                            Button(item){
                                if preference(text: item){
                                    vm.deleteUserPreference(text: item)
                                }else{
                                    vm.addUserPreference(text: item)
                                }
                            }.buttonStyle(.borderedProminent)
                                .font(.headline)
                                .tint(preference(text: item) ?  .green : .red)
                        }
                    }
                    Text("사용자 선호 : \((user.preference ?? []).joined(separator: ", "))")
                }
                Button {
                    if user.favoriteMovie == nil{
                        vm.favoriteMovie()
                    }else{
                        vm.deleteFavoriteMovie()
                    }
                } label: {
                    Text("좋아하는 영화 : \((user.favoriteMovie?.title ?? ""))")
                }

            }
        }
        .task{
            try? await vm.loadCurrentUser()
            //메서드 내에서 에러처리를 하지 않았기 때문에 옵셔널 선언
        }
        .navigationTitle("프로필")
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                NavigationLink {
                    SettingView(showSignInView: $showSignView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
//        NavigationStack{
//            ProfileView(showSignView: .constant(false))
//        }
        RootView()
    }
}
