//
//  ProductManager.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/14.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

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
    
    private func getAllProducts() async throws -> [Product]{
        try await productCollection
            .limit(to: 5)   //페이지수 5개로 고정
            .getDocuments2(as: Product.self)
    }
    
    private func getAllProductSortByPrice(descending:Bool) async throws -> [Product]{
        try await productCollection
            .order(by: "price",descending: descending)
            .getDocuments2(as: Product.self)
    }
    private func getAllProductSortByCategory(category:String) async throws -> [Product]{
        try await productCollection
            .whereField("category", isEqualTo: category)
            .getDocuments2(as: Product.self)
    }
    private func getAllProductSortByCategoryPrice(descending:Bool,category:String) async throws -> [Product]{
        try await productCollection
            .whereField("category", isEqualTo: category)
            .order(by: "price",descending: descending)
            .getDocuments2(as: Product.self)
    }
    func getAllProducts(descending:Bool?,category:String?) async throws -> [Product]{
        if let descending,let category{
            return try await getAllProductSortByCategoryPrice(descending: descending, category: category)
        }else if let descending{
            return try await getAllProductSortByPrice(descending: descending)
        }else if let category{
            return try await getAllProductSortByCategory(category: category )
        }
        return try await getAllProducts()
    }
}



extension Query{    //코드 확장성을 위해 제네릭으로 사용
    func getDocuments2<T>(as types : T.Type)async throws -> [T] where T:Decodable{
        let snapshot = try await self.getDocuments()
        
        return try snapshot.documents.map({document in
            try document.data(as: T.self)
        })
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




