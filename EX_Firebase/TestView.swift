//
//  TestView.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/26.
//

import SwiftUI

class AA{
    static let aa = AA()
    
    func BBB() -> String{
        return "sdasd"
    }
}
class AAA:ObservableObject{
    @Published var aa = ""
    
    func aaChange(){
        aa = AA.aa.BBB()
    }
    func aaChange1(){
        aa = "sadasd"
    }
    func aaChange2(){
        aa = "sadasd"
    }
}
struct TestView: View {
    @State var vm = AAA()
    var body: some View {
        VStack{
            Text(vm.aa)
            Button {
                vm.aaChange()
            } label: {
                Image(systemName: "heart")
            }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
