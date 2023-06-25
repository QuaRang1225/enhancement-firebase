//
//  HomeView.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/21.
//

import SwiftUI

struct HomeView: View {
    @StateObject var vm = DBViewModel()
    var body: some View {
        NavigationView {
            ScrollView {
                VStack{
                    ForEach(vm.dard){ i in
                        Text(i.title)
                            .contextMenu {
                                Button {
                                    vm.delete(object: i)
                                } label: {
                                    Text("adasd")
                                }

                            }
                    }
                    
                }
            }
            .navigationTitle("asdasd")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    Button {
                        vm.opnNewPage.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }

                }
            }
            .sheet(isPresented: $vm.opnNewPage) {
                AddPageView()
                    .environmentObject(vm)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
