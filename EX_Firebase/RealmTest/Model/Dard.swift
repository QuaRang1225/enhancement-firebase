//
//  Dard.swift
//  EX_Firebase
//
//  Created by 유영웅 on 2023/06/21.
//

import Foundation
import SwiftUI
import RealmSwift

class Dardd:Object,Identifiable{
    
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var detail: String
    
}

