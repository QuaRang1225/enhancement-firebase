//
//  FavoriteView.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/26.
//

import SwiftUI
import Kingfisher
import Combine

@MainActor
final class FavoriteViewModel:ObservableObject{
    var cancaellabels = Set<AnyCancellable>()
    @Published var products:[UserFavoritProduct] = []
    
    func addListenerForFavorite(){  //실시간으로 데이터를 업데이트 시킴
        guard let authDataReslut = try? AuthenticationManager.shared.getUser() else {return}
//        UserManager.shared.addListenerAlluserFavoriteProducts(userId: authDataReslut.uid) { [weak self] product in  //completion은 비동기식 호출이기 때문에 메서드 호출이 끝나면 반환값을 컴파일러는 모르기 때문에 약한 참조 사용
//            self?.product = product
//        }
        UserManager.shared.addListenerAlluserFavoriteProducts(userId: authDataReslut.uid)
            .sink { completion in
                
            } receiveValue: { [weak self] products in
                self?.products = products
            }.store(in: &cancaellabels)

    }
    
//    func getFavorites(){  //실시간 업데이트가 되지 않음
//        Task{
//            let authDataReslut = try AuthenticationManager.shared.getUser()
//            self.products = try await UserManager.shared.getAllUserFavoriteProduct(userId: authDataReslut.uid )
//
//        }
//
//    }
    func removeFromFavorite(favoriteProductId:String){
        Task{
            let authDataReslut = try AuthenticationManager.shared.getUser()
            try? await UserManager.shared.removeUserFavoriteProduct(userId:authDataReslut.uid,favoriteProductId:favoriteProductId)
//            getFavorites()    //실시간데이터를 불러오기 때문에 불러올 필요성 사라짐
        }
    }
}
struct FavoriteView: View {
    @StateObject var vm = FavoriteViewModel()
    var body: some View {
        List{
            ForEach(vm.products,id:\.id.self) { pro in  //제품 분간기준 id로 했기때문
                ProductRowViewBuilder(productId: String(pro.productId))
                    .contextMenu{
                        Button("삭제"){
                            vm.removeFromFavorite(favoriteProductId: pro.id)
                        }
                    }
            }
        }
        .navigationTitle("찜목록")
        .onFirstAppear {
            vm.addListenerForFavorite()
        }
    }
}

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteView()
    }
}


struct OnFirstAppearCiewModifier:ViewModifier{
    @State var didAppear = false
    let perform:(() -> Void)?
    func body(content: Content) -> some View {
        content
            .onAppear{
                if !didAppear{  //이게 없으면 리스트가 계속 생겨남
                    perform?()
                    didAppear = true
                }
                
            }
    }
}


extension View{
    func onFirstAppear(perform:(()->Void)?) -> some View{
        modifier(OnFirstAppearCiewModifier(perform: perform))
    }
}
