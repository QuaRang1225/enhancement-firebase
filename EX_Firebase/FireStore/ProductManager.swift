//
//  ProductManager.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/14.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

final class ProductManager{
    
    static let shared = ProductManager()
    private init(){}
    
    private let productCollection = Firestore.firestore().collection("products")
    
    private func productDocument(productId:String) -> DocumentReference{
        productCollection.document(productId)
    }
    
    func uploadProduct(product:Product)async throws{
        try productDocument(productId: String(product.id)).setData(from: product,merge: false)  //merge - true 병합(기존 문서에 추가 혹은 업데이트)  //fase 대체(기존 문서로 덮어씀 완전 교체)
    }
    
//    private func getAllProducts() async throws -> [Product]{
//        try await productCollection
////            .limit(to: 5)   //페이지수 5개로 고정
//            .getDocuments2(as: Product.self)
//    }
//
//    private func getAllProductSortByPrice(descending:Bool) async throws -> [Product]{
//        try await productCollection
//            .order(by: "price",descending: descending)
//            .getDocuments2(as: Product.self)
//    }
//    private func getAllProductSortByCategory(category:String) async throws -> [Product]{
//        try await productCollection
//            .whereField("category", isEqualTo: category)
//            .getDocuments2(as: Product.self)
//    }
//    private func getAllProductSortByCategoryPrice(descending:Bool,category:String) async throws -> [Product]{
//        try await productCollection
//            .whereField("category", isEqualTo: category)
//            .order(by: "price",descending: descending)
//            .getDocuments2(as: Product.self)
//    }
    
    private func getAllProductsQuery()-> Query{
        productCollection
//            .limit(to: 5)   //페이지수 5개로 고정
    }
    func getProduct(productId:String) async throws -> Product{
        try await productDocument(productId: productId).getDocument(as: Product.self)
    }
    
    private func getAllProductSortByPriceQuery(descending:Bool)  -> Query{
       productCollection
            .order(by: "price",descending: descending)
    }
    private func getAllProductSortByCategoryQuery(category:String) -> Query{
        productCollection
            .whereField("category", isEqualTo: category)
    }
    private func getAllProductSortByCategoryPriceQuery(descending:Bool,category:String)  -> Query{
        productCollection
            .whereField("category", isEqualTo: category)
            .order(by: "price",descending: descending)
    }
    func getAllProducts(descending:Bool?,category:String?,count:Int,lastDocument:DocumentSnapshot?) async throws -> ([Product],DocumentSnapshot?){
        
        var query:Query = getAllProductsQuery()
        
        if let descending,let category{
            query =  getAllProductSortByCategoryPriceQuery(descending: descending, category: category)
        }else if let descending{
            query =  getAllProductSortByPriceQuery(descending: descending)
        }else if let category{
            query = getAllProductSortByCategoryQuery(category: category )
        }
        return try await query
            .limit(to: count)
            .startOptiaonal(afterDocumnet: lastDocument)
            .getDocumentSnapshot(as: Product.self)
    }
    func allProductCount()async throws -> Int{
        try await productCollection.aggregateCount()
    }
    
    
//
//    func getProductByRationg(count:Int,lastRating:Double?) async throws -> [Product]{
//        try await productCollection
//            .order(by:"rating",descending: true)
//            .limit(to: count)
//            .start(after: [lastRating ?? 999999])
//            .getDocuments2(as: Product.self)
//    }
//    func getProductByRationg(count:Int,lastDocument:DocumentSnapshot?) async throws -> (product : [Product],lastDocument:DocumentSnapshot?){
//        if let lastDocument{
//            return try await productCollection
//                .order(by:"rating",descending: true)
//                .limit(to: count)
//                .start(afterDocument: lastDocument)
//                .getDocumentSnapshot(as: Product.self)
//        }else{
//            return try await productCollection
//                .order(by:"rating",descending: true)
//                .limit(to: count)
//                .getDocumentSnapshot(as: Product.self)
//        }

//    }
    
    
}



extension Query{    //코드 확장성을 위해 제네릭으로 사용
//    func getDocuments2<T>(as types : T.Type)async throws -> [T] where T:Decodable{
//        let snapshot = try await self.getDocuments()
//
//        return try snapshot.documents.map({document in
//            try document.data(as: T.self)
//        })
//    }
    func getDocuments2<T>(as types : T.Type)async throws -> [T] where T:Decodable{
       try await getDocumentSnapshot(as:types).product
    }
    func getDocumentSnapshot<T>(as types : T.Type)async throws -> (product : [T],lastDocument:DocumentSnapshot?) where T:Decodable{
        let snapshot = try await self.getDocuments()
        
        let product = try snapshot.documents.map({document in
            try document.data(as: T.self)
        })
        return (product,snapshot.documents.last)
    }
    
    func startOptiaonal(afterDocumnet:DocumentSnapshot?) ->Query{
        guard let afterDocumnet else{ return self }
        return self.start(afterDocument: afterDocumnet)
    }
    
    func aggregateCount() async throws-> Int{
        let snapshot = try await self.count.getAggregation(source:.server)   //쿼리문서수 계산 빍드 리딩 시간 절약
        return Int(truncating: snapshot.count)
    }
    func addSnapShotListener<T>(as type:T.Type) -> (AnyPublisher<[T],Error>,ListenerRegistration) where T : Decodable{
        let publisher = PassthroughSubject<[T],Error>()
        let listener = self.addSnapshotListener { querySnapshot, error in
            guard let document = querySnapshot?.documents else{
                print("문서가 없습니다.")
                return
            }
            let products:[T] = document.compactMap( { try? $0.data(as: T.self)})
            publisher.send(products)
        }
        return (publisher.eraseToAnyPublisher(),listener)
    }
}
//func getAllProducts() async throws -> [Product]{
//    let snapshot = try await productCollection.getDocuments()
//
//    var prodcuts:[Product] = []
//    for document in snapshot.documents{
//        let product = try document.data(as: Product.self)
//        prodcuts.append(product)
//    }
//    return prodcuts
//}




