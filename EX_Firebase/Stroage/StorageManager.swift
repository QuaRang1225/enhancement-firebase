//
//  StarageManager.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/07/05.
//

import Foundation
import FirebaseStorage
import UIKit

final class StorageManager{
    
    static let shared = StorageManager()
    private init() {}
    
    private let storage = Storage.storage().reference() //db루트 참조위치
    private var imagesReferance:StorageReference{
        storage.child("images")
    }
    private func userReferance(userId:String) -> StorageReference{
        storage.child("users").child(userId)
    }
    func getPathForImage(path:String) -> StorageReference{
        Storage.storage().reference(withPath: path)
    }
    func getUtlForImage(path:String) async throws -> URL{
        try await getPathForImage(path: path).downloadURL()
    }
    
//    func getData(userId:String,path:String)async throws -> Data{
//        try await storage.child(path).data(maxSize: 15 * 1024 * 1024)  //설정 사이즈보다 큰 사진일 경우 다운로드 불가
//    }
//    func getImage(userId:String,path:String)async throws -> UIImage{
//        let data = try await storage.child(path).data(maxSize: 15 * 1024 * 1024)  //설정 사이즈보다 큰 사진일 경우 다운로드 불가
//        guard let image = UIImage(data: data) else {
//            throw URLError(.badServerResponse)
//        }
//        return image
//    }
    func saveImage(data:Data,userId:String)async throws -> (String,String){
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await userReferance(userId: userId).child(path).putDataAsync(data,metadata: meta)
        
        guard let returnedpPath = returnedMetaData.path, let returnedName = returnedMetaData.name else{
            throw URLError(.badServerResponse)
        }
        
        return (returnedpPath,returnedName)
        
    }
    
    func saveImage(image:UIImage,userId:String) async throws -> (String,String){
        //png - 투명한 배경
        //jpeg - 용량 덜 차지
        guard let data = image.jpegData(compressionQuality: 1)else{
            throw URLError(.backgroundSessionWasDisconnected)
        }
        return try await saveImage(data: data, userId: userId)
    }
    func deleteImage(path:String) async throws{
        try await getPathForImage(path: path).delete()
    }
}
