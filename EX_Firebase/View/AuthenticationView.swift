//
//  AuthenticationView.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/12.
//

import SwiftUI

struct AuthenticationView: View {
    @Binding var showSignView:Bool
    var body: some View {
        VStack{
            NavigationLink {
                SignEmailView(showSignView: $showSignView)
            } label: {
                Text("이메일로 로그인")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            Spacer()
                
        }
        .padding()
        .navigationTitle("로그인")
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            AuthenticationView(showSignView: .constant(false))
        }
        
    }
}
