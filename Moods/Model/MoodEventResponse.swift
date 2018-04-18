//
//  MoodEventResponse.swift
//  Moods
//
//  Created by Santiago Moreno on 5/02/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import Foundation

class MoodEventResponse{
    private var _idInServer:String!
    private var _label:String!
    private var _quantity:Int!
    
    var idInServer:String{
        get {
            return _idInServer
        }
        set {
            _idInServer = newValue
        }
    }
    
    var label:String{
        get {
            return _label
        }
        set {
            _label = newValue
        }
    }
    
    var quantity:Int{
        get {
            return _quantity
        }
        set {
            _quantity = newValue
        }
    }
    
    init(idInServer:String,label:String,quantity:Int) {
        self._idInServer = idInServer
        self._label = label
        self._quantity = quantity
    }
    
}
