//
//  RootView.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/12.
//

import SwiftUI

struct RootView: View {
    @State private var showSignInView = false
    var body: some View {
        ZStack{
            NavigationStack{
//                ProfileView(showSignView: $showSignInView)
                ProductView()
            }
        }
        .onAppear{
            let authUser = try? AuthenticationManager.shared.getUser()  //오류메세지를 확인할 필요가 없으니까 굳이 do catch로 나눌 필요가 앖음
            self.showSignInView = authUser == nil ? true:false  //유저 정보가 저장되어있을 경우 세팅/아닐 경우 로그인
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack{
                AuthenticationView(showSignView: $showSignInView)
               
            }
            
        }
        
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
