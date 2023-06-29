//
//  SignEmailView.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/12.
//

import SwiftUI

@MainActor
final class SignEmailViewModel:ObservableObject{
    
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws{
        guard !email.isEmpty,!password.isEmpty else{
            print("이메일과 패스워드를 입력하지 않았습니다.")
            return
        }
        let authUser = try await AuthenticationManager.shared.createUser(email: email, password: password) //값을 굳이 안쓰고 컴파일러에 값이 있을
        let user = UserDataBase(auth: authUser)
        try await UserManager.shared.createNewUser(user: user)
        print("가입 성공")
    }
    func signIn() async throws{
        guard !email.isEmpty,!password.isEmpty else{
            print("이메일과 패스워드를 입력하지 않았습니다.")
            return
        }
//        let _ = try await AuthenticationManager.shared.signInUser(email: email, password: password)   //이렇게 안하려면  @discardableResult 사용
        try await AuthenticationManager.shared.signInUser(email: email, password: password) //값을 굳이 안쓰고 컴파일러에 값이 있을
        print("인증 성공")
    }
    
}

struct SignEmailView: View {
    @Binding var showSignView:Bool
    @StateObject private var vm = SignEmailViewModel()
    var body: some View {
        VStack{
            
            TextField("로그인",text: $vm.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            SecureField("비밀번호",text: $vm.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            Button {
                Task{
                    do{
                       try await vm.signUp()
                        showSignView = false
                        return  //리턴을 하지 못하면 다음으로 넘어감
                    } catch{
                        print(error)
                    }
                    do{
                       try await vm.signIn()
                        showSignView = false
                        return
                    } catch{
                        print(error)
                    }
                }
                
            } label: {
                Text("회원가입")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("이메일로 회원가입")
    }
}

struct SignEmailView_Previews: PreviewProvider {
    static var previews: some View {
        SignEmailView(showSignView: .constant(false))
    }
}
