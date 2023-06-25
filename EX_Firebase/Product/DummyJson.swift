//
//  DummyJson.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/14.
//

import Foundation


struct DummyJson:Codable{
    
    let products:[Product]
    let total,skip,limit:Int

}
struct Product: Identifiable,Codable,Equatable {    //Equatable
    let id: Int
    let title, description: String?
    let price: Int?
    let discountPercentage, rating: Double?
    let stock: Int?
    let brand, category: String?
    let thumbnail: String?
    let images: [String]?
    
    static func == (lhs:Product,rhs:Product)->Bool{
        return lhs.id == rhs.id
    }
}

