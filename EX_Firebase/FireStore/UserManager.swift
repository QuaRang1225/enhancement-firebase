//
//  UserManager.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/13.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore
import Combine

struct Movie:Codable{
    let id:String
    let title:String
    let isPopular:Bool
}
struct UserDataBase:Codable{
    
    let userId:String
    let email:String?
    let dateCreated:Date?
    var isPremium:Bool?
    let preference:[String]?
    let favoriteMovie:Movie?
    
    init(auth:AuthDataResult){  //처음 값을 저장할때 - 인증
        self.userId = auth.uid
        self.email = auth.email
        self.dateCreated = Timestamp().dateValue()
        self.isPremium = false
        self.preference = nil
        self.favoriteMovie = nil
    }
    init(userId:String, email:String?,dateCreated:Date?,isPremium:Bool?,preference:[String]?,favoriteMovie:Movie?){ //값이 바뀐 후 업데이트
        self.userId = userId
        self.email = email
        self.dateCreated = dateCreated
        self.isPremium = isPremium
        self.preference = preference
        self.favoriteMovie = favoriteMovie
    }
    
//    func togglePremium() -> UserDataBase{
//        let currentValue = isPremium ?? false
//        return UserDataBase(userId: userId, email: email, dateCreated: dateCreated, isPremium: !currentValue)
//    }
//    mutating func togglePremium(){  //struct의 프로퍼티를 직접 수정가능
//        let currentValue = isPremium ?? false
//        self.isPremium = !currentValue
//    }
}

final class UserManager{
    
    static let shared = UserManager()
    private init(){}
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId:String) -> DocumentReference{
        userCollection.document(userId)
    }
    
    private func userFavoriteProductCollection(userId:String)->CollectionReference{
        userDocument(userId: userId).collection("favorite_product")
    }
    private func userFavoriteProdctDocument(userId:String,favoriteProductId:String) -> DocumentReference{
        userFavoriteProductCollection(userId: userId).document(favoriteProductId)
    }
    
    private let encoder:Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase   //ex) dateCreadted -> datae_created
        return encoder
    }()
    private let decoder:Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase //datae_created -> dateCreadted
        return decoder
    }()
    
    private var userFavoriteProductListener:ListenerRegistration? = nil
    
    func createNewUser(user:UserDataBase) async throws{ //async throws 로 선언된 메서드만 await로 호출가능
        try userDocument(userId:user.userId).setData(from: user,merge: false,encoder: encoder)
    }
    
//    func createNewUser(auth:AuthDataResult) async throws{
//        var userData:[String:Any] = [
//            "userId" : auth.uid,
//            "date_created" : Timestamp()
//        ]
//
//        if let email = auth.email{
//            userData["email"] = email
//        }
//        try await  userDocument(userId:auth.uid).setData(userData,merge: false)
//    }
    func getUser(userId:String) async throws -> UserDataBase{
        try await userDocument(userId: userId).getDocument(as: UserDataBase.self,decoder: decoder)
    }
//    func getUser(userId:String) async throws -> UserDataBase{
//        
//        let snapshot = try await userDocument(userId:userId).getDocument()
//        guard let data = snapshot.data(),let userId = data["userId"] as? String else {
//            throw URLError(.badServerResponse)
//        }
//        
//        let email = data["email"] as? String
//        let date = data["date_created"] as? Timestamp
//        
//        
//        return UserDataBase(userId: userId, email: email, dateCreated: date?.dateValue())
//    }
    
//    func updateUserPreminumStatus(user:UserDataBase)async throws{
//        try userDocument(userId: user.userId).setData(from: user,merge: true,encoder: encoder)
//    }
    func updateUserPreminumStatus(userId:String,isPremium:Bool)async throws{
        let data:[String:Any] = ["is_premium":isPremium]
        try await userDocument(userId:userId).updateData(data)
    }
    
    func addUserPreference(userId:String,preference:String) async throws{       //단순 값형태일 경우(String,Int,Bool등등)
        let data:[String:Any] = ["preference":FieldValue.arrayUnion([preference])]  //배열 중복제거 업데이트 FieldValue.arrayUnion
        try await userDocument(userId:userId).updateData(data)
    }
    func deleteUserPreference(userId:String,preference:String) async throws{
        let data:[String:Any] = ["preference":FieldValue.arrayRemove([preference])]
        try await userDocument(userId:userId).updateData(data)
    }
    func favoriteMovie(userId:String,movie:Movie) async throws{     //구조체자체일 경우(Movie)인코딩작업을 하고 업데이트
        guard let data = try? encoder.encode(movie) else{
            throw URLError(.badURL)
        }
        let dict:[String:Any] = ["favorite_movie":data]
        try await userDocument(userId:userId).updateData(dict)
    }
    func deleteFavoriteMovie(userId:String) async throws{
        let data:[String:Any?] = ["favorite_movie":nil]
        try await userDocument(userId:userId).updateData(data as [AnyHashable : Any])
    }
    
    
    func addUserFavoriteProduct(userId:String,productId:Int)async throws{
        let document = userFavoriteProductCollection(userId: userId).document()
        let documentId = document.documentID
        
        let data:[String:Any] = [
            "id" : documentId,
            "product_id" : productId,
            "date_created" : Timestamp()
        ]
        try await document.setData(data,merge: false)
    }
    
    func removeUserFavoriteProduct(userId:String,favoriteProductId:String)async throws{
        try await userFavoriteProdctDocument(userId: userId, favoriteProductId: favoriteProductId).delete()
    }
    func getAllUserFavoriteProduct(userId:String)async throws -> [UserFavoritProduct]{
        try await userFavoriteProductCollection(userId: userId).getDocuments2(as: UserFavoritProduct.self)
    }
    
    func removeListenerForAllUserFavoriteProdcut2(){    //ex)리스러 종료
        self.userFavoriteProductListener?.remove()
    }
    func addListenerAlluserFavoriteProducts(userId:String,compeletion:@escaping ([UserFavoritProduct]) -> Void){
        let listenler = userFavoriteProductCollection(userId: userId).addSnapshotListener { querySnapshot, error in
            guard let document = querySnapshot?.documents else{
                print("문서가 없습니다.")
                return
            }
            
            let products:[UserFavoritProduct] = document.compactMap( { try? $0.data(as: UserFavoritProduct.self)})
            compeletion(products)
        }
        self.userFavoriteProductListener = listenler
    }
    
//    func addListenerAlluserFavoriteProducts(userId:String) -> PassthroughSubject<[UserFavoritProduct],Error>{
//        let publisher = PassthroughSubject<[UserFavoritProduct],Error>()
//
//        self.userFavoriteProductListener = userFavoriteProductCollection(userId: userId).addSnapshotListener { querySnapshot, error in
//            guard let document = querySnapshot?.documents else{
//                print("문서가 없습니다.")
//                return
//            }
//
//            let products:[UserFavoritProduct] = document.compactMap( { try? $0.data(as: UserFavoritProduct.self)})
//            publisher.send(products)
//        }
//        return publisher.eraseToAnyPublisher()
//    }
    func addListenerAlluserFavoriteProducts(userId:String) -> AnyPublisher<[UserFavoritProduct],Error>{
        let (publisher,listener) = userFavoriteProductCollection(userId: userId)
            .addSnapShotListener(as:UserFavoritProduct.self)
        self.userFavoriteProductListener = listener
        return publisher
    }
    
}

struct UserFavoritProduct:Codable{
    let id:String
    let productId:Int
    let dateCreated:Date
    
    enum CodingKeys:String,CodingKey{
        case id
        case productId = "product_id"
        case dateCreated = "date_created"
    }
}
