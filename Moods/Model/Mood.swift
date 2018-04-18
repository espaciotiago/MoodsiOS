//
//  Mood.swift
//  Moods
//
//  Created by Santiago Moreno on 8/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import Foundation
class Mood {
    private var _idInServer:String!
    private var _mood:String!
    private var _value:Int!
    
    var idInServer:String{
        get{
            return _idInServer
        }
        set{
            _idInServer = newValue
        }
    }
    var mood:String{
        get{
            return _mood
        }
        set{
            _mood = newValue
        }
    }
    var value:Int{
        get{
            return _value
        }
        set{
            _value = newValue
        }
    }
    
    init(idInServer:String,mood:String,value:Int) {
        self._idInServer = idInServer
        self._mood = mood
        self._value = value
    }
}
