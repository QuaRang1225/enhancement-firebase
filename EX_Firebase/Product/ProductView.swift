//
//  ProductView.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/14.
//

import SwiftUI
import Kingfisher
@MainActor
final class ProductViewModel:ObservableObject{
    @Published var products:[Product] = []
    @Published var selectFilter:FilterOption? = nil
    @Published var selectCategoryFilter:CategoryOption? = nil
//
//    func getAllProdcut() async throws{
//        self.products = try await ProductManager.shared.getAllProducts()
//    }
    func downloadData(){    //한번만 실행
        guard let url = URL(string: "https://dummyjson.com/products") else {return}

        Task{
            do{
                let (data,_) = try await URLSession.shared.data(from: url)
                let product = try JSONDecoder().decode(DummyJson.self, from: data)
                let productArray = product.products

                for product in productArray {
                    try await ProductManager.shared.uploadProduct(product: product)
                }
                print("성공")
                print(product.products.count)
            }catch{
                print(error)
            }
        }
    }
    enum FilterOption:String,CaseIterable{
        case none
        case priceHigh
        case priceLow
        
        var categoryKey:String?{
            if self == .none{
                return nil
            }
            return self.rawValue
        }
        
        var priceDescending:Bool?{
            switch self{
            case .none: return nil
            case .priceHigh: return true
            case .priceLow: return false
            }
        }
    }
    enum CategoryOption:String,CaseIterable{
        case none
        case smartphones
        case laptops
        case fragrances
        
        var categoryKey:String?{
            if self == .none{
                return nil
            }
            return self.rawValue
        }
    }
    
    
    func filterSelected(option:FilterOption) async throws{
        self.selectFilter = option
        self.getProduct()
    }
    func categorySelected(option:CategoryOption) async throws{

        self.selectCategoryFilter = option
        self.getProduct()
    }
    
    
    func getProduct() {
        Task{
            self.products = try await ProductManager.shared.getAllProducts(descending: selectFilter?.priceDescending, category: selectCategoryFilter?.rawValue)
        }
    }
}

struct ProductView: View {
    @StateObject var vm = ProductViewModel()
    var body: some View {
        List{
            ForEach(vm.products) { pro in
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
           
        }.navigationTitle("프로덕션")
            .toolbar{
                ToolbarItem(placement:.navigationBarLeading){
                    Menu("가격 필터 : \(vm.selectFilter?.rawValue ?? "none")"){
                        ForEach(ProductViewModel.FilterOption.allCases,id:\.self) { filter in
                            Button {
                                Task{
                                    try? await vm.filterSelected(option: filter)
                                }
                            } label: {
                                Text(filter.rawValue)
                            }
                        }
                    }
                }
                ToolbarItem(placement:.navigationBarTrailing){
                    Menu("제품 필터 : \(vm.selectCategoryFilter?.rawValue ?? "none")"){
                        ForEach(ProductViewModel.CategoryOption.allCases,id:\.self) { filter in
                            Button {
                                Task{
                                    try? await vm.categorySelected(option: filter)
                                }
                            } label: {
                                Text(filter.rawValue)
                            }
                        }
                    }
                }
            }
        .onAppear {
            vm.getProduct()   //에러처리를 안했기 때문에 try? 형태를 쓴다
        }
    }
}

struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            ProductView()
        }
    }
}
