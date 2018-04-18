//
//  FormOption.swift
//  Moods
//
//  Created by Santiago Moreno on 7/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import Foundation
class FormOption {
    private var _idInServer:String!
    private var _label:String!
    private var _checked:Bool!
    private var _value:Int!
    
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
    var checked:Bool{
        get {
            return _checked
        }
        set {
            _checked = newValue
        }
    }
    var value:Int{
        get {
            return _value
        }
        set {
            _value = newValue
        }
    }
    
    init(idInServer:String,label:String,checked:Bool,value:Int) {
        self._idInServer = idInServer
        self._label = label
        self._checked = checked
        self._value = value
    }
    
    init() {
        self._checked = false
        self._idInServer = ""
        self._label = ""
        self._value = 0
    }
}
