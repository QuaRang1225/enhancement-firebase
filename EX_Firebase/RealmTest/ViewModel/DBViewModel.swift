//
//  DBViewModel.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/21.
//

import Foundation
import RealmSwift


class DBViewModel: ObservableObject{
    
    @Published var title = ""
    @Published var detail = ""
    
    @Published var opnNewPage = false
    @Published var dard:[Dardd] = []
    
    init(){
        fetcData()
    }
    func fetcData(){
        guard let db = try? Realm() else{return}
        let result = db.objects(Dardd.self)
        self.dard = result.compactMap({ (dard) -> Dardd? in
            return dard
        })
    }
    func addDate(){
        let dard = Dardd()
        dard.title = title
        dard.detail = detail
        
        guard let db = try? Realm() else{return}
        
        try? db.write{
            db.add(dard)
            fetcData()
        }
    }
    
    func delete(object:Dardd){
        guard let db = try? Realm() else{return}
        try? db.write{
            db.delete(object)
            fetcData()
        }
    }
}
