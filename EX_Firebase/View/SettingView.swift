//
//  SettingView.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/12.
//

import SwiftUI

@MainActor
final class SettingViewModel:ObservableObject{
    

    func signOut() throws{
        try AuthenticationManager.shared.signOut()
    }
    func resetPassword()async throws{
        let user = try AuthenticationManager.shared.getUser()
        guard let email = user.email else{
            throw URLError(.badServerResponse)
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    func updateEmail()async throws{
        let email = "quarang1225@gmail.com"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    func updatePassword()async throws{
        let password = "hero1225@"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    func delete() async throws{
        try await AuthenticationManager.shared.delete()
    }
}

struct SettingView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = SettingViewModel()
    @Binding var showSignInView:Bool
    var body: some View {
        List{
            Section("이메일") {
                Button("이메일 재설정"){
                    Task{
                        do{
                            try await vm.updateEmail()
                            print("이메일 변경됨")
                        }catch{
                            print(error)
                        }
                    }
                }
                Button("비밀번호 리셋"){  //이메일로 전송 후 변경
                    Task{
                        do{
                            try await vm.resetPassword()
                            print("비밀번호 리셋")
                        }catch{
                            print(error)
                        }
                    }
                }
                
                Button("비밀번호 재설정"){ //앱에서 직접 변경
                    Task{
                        do{
                            try await vm.updatePassword()
                            print("비밀번호 변경됨")
                        }catch{
                            print(error)
                        }
                    }
                }
            }
           
            Button("로그아웃"){
                Task{
                    do{
                        try vm.signOut()
                        showSignInView = true
                        dismiss()
                    }catch{
                        print(error)
                    }
                }
            }
            Button(role: .destructive) {
                Task{
                    do{
                        try await vm.delete()
                        showSignInView = true
                        dismiss()
                    }catch{
                        print(error)
                    }
                }
            } label: {
                Text("계정탈퇴")
            }


        }.navigationTitle("설정")
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(showSignInView: .constant(false))
    }
}
