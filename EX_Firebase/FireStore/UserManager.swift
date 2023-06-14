//
//  UserManager.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/13.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

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
}
