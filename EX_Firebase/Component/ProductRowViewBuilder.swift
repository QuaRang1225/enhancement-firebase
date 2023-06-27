//
//  ProductRowViewBuilder.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/27.
//

import SwiftUI

struct ProductRowViewBuilder: View {    //한번에 모든 리스트Row를 가져오지 않게 하기 위해(보여지는 뷰를 우선적으로 불러오기 위함)
    let productId:String
    @State var product:Product? = nil
    
    var body: some View {
        ZStack{
            if let product{
                ProductRowView(pro: product)
            }
        }
        .task{
            self.product = try? await ProductManager.shared.getProduct(productId: productId)
        }
    }
}

struct ProductRowViewBuilder_Previews: PreviewProvider {
    static var previews: some View {
        ProductRowViewBuilder(productId: "1")
    }
}
