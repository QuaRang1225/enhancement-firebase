//
//  AuthenticationManagr.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/12.
//

import Foundation
import FirebaseAuth

struct AuthDataResult{
    let uid:String
    let email:String?
    
    init(user:User) {   //코드의 간결성을 위해 같은 메서드의 값일 경우 이렇게 일체화 가능
        self.uid = user.uid
        self.email = user.email
    }
}
final class AuthenticationManager{
    
    static let shared = AuthenticationManager()
    private init(){}    //중복된 객체 생성 방지
    
    @discardableResult //리턴값을 사용하지 않아도 warning이 나오지 않도록 설정할 수 있음
    func createUser(email:String,password:String) async throws-> AuthDataResult{
        let authDataResult = try await Auth.auth().createUser(withEmail:email,password:password)
        return AuthDataResult(user: authDataResult.user) //authDataResult.user - 유저정보(email,password,프로필이미지)
        
    }
    
    @discardableResult 
    func signInUser(email:String,password:String) async throws-> AuthDataResult{
        let authDataResult = try await Auth.auth().signIn(withEmail:email,password:password)
        return AuthDataResult(user: authDataResult.user) //authDataResult.user - 유저정보(email,password,프로필이미지)
        
    }
    
    func getUser() throws -> AuthDataResult{        //데이터를 가져오는것이 아니고 그냥 값을 확인할 경우에는 비동기 이빈트일 필요가 없기 때문에 async를 사용하지 않음(서버로 도달하지 않고 로컬에서 데이터를 구분함)
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        return AuthDataResult(user: user)
    }
    
    func resetPassword(email:String) async throws{
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    func updatePassword(password:String)async throws{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: password)
    }
    func updateEmail(email:String)async throws{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        try await user.updateEmail(to: email)
    }
    
    func signOut() throws{
        try Auth.auth().signOut()
    }
    
    func delete() async throws{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        try await user.delete()
    }
}
