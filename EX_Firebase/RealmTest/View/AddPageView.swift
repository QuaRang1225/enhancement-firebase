//
//  AddPageView.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/21.
//

import SwiftUI

struct AddPageView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm:DBViewModel
    var body: some View {
        NavigationView {
            List{
                Section(header: Text("adasd")) {
                    TextField("",text: $vm.title)
                }
                Section(header: Text("adasd")) {
                    TextField("",text: $vm.detail)
                }
            }.listStyle(.grouped)
                .navigationTitle("dasda")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing){
                            Button {
                                vm.addDate()
                                dismiss()
                            } label: {
                                Text("adasd")
                            }

                        }
                    }
        }
    }
}

struct AddPageView_Previews: PreviewProvider {
    static var previews: some View {
        AddPageView()
    }
}
