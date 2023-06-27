//
//  ProductRowView.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/26.
//

import SwiftUI
import Kingfisher

struct ProductRowView: View {
    let pro:Product
    var body: some View {
        HStack(alignment: .top){
            KFImage(URL(string: pro.thumbnail!))
                .resizable()
                .frame(width: 50,height: 50)
                .cornerRadius(10)
            
            VStack(alignment: .leading,spacing:5){
                Text(pro.title ?? "")
                    .font(.body)
                    .foregroundColor(.primary)
                Text("$" + String(pro.price ?? 0))
                Text("설명 : " + String(pro.description ?? ""))
                Text("순위 : " + String(pro.rating ?? 0.0))
                Text("브랜드 : " + String(pro.brand ?? ""))
                Text("카테고리 : " + String(pro.category ?? ""))
            }.font(.callout)
                .foregroundColor(.secondary)
        }
    }
}

//struct ProductRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProductRowView(product: Product(id: <#T##Int#>, title: <#T##String?#>, description: <#T##String?#>, price: <#T##Int?#>, discountPercentage: <#T##Double?#>, rating: <#T##Double?#>, stock: <#T##Int?#>, brand: <#T##String?#>, category: <#T##String?#>, thumbnail: <#T##String?#>, images: <#T##[String]?#>))
//    }
//}
