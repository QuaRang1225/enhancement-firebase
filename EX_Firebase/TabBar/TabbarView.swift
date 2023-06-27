//
//  TabbarView.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/26.
//

import SwiftUI

struct TabbarView: View {
    @Binding var showSignInView:Bool
    var body: some View {
        TabView {
            NavigationStack{
                ProductView()
            }
            .tabItem {
                Image(systemName: "cart")
            }
            NavigationStack{
                FavoriteView()
            }
            .tabItem {
                Image(systemName: "star")
            }
            NavigationStack{
                ProfileView(showSignView: $showSignInView)
            }
            .tabItem {
                Image(systemName: "person")
            }
        }
    }
}

struct TabbarView_Previews: PreviewProvider {
    static var previews: some View {
        TabbarView(showSignInView: .constant(true))
    }
}
