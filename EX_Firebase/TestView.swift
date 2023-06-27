//
//  TestView.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/26.
//

import SwiftUI

struct TestView: View {
    @State var num = "\(56)"
    var body: some View {
        VStack{
            Text(num)
            Button {
              let value = pow(10, Int(num.count))
            let value1 = Decimal(Double(num)!)/value

                num = "\(value1)"
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
