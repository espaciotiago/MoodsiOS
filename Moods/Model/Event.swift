//
//  Event.swift
//  Moods
//
//  Created by Santiago Moreno on 7/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import Foundation
class Event{
    private var _idInServer:String!
    private var _label:String!
    private var _extraText:String!
    private var _checked:Bool!
    
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
    
    var extraText:String{
        get {
            return _extraText
        }
        set {
            _extraText = newValue
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
    
    init(idInServer:String,label:String,extraText:String,checked:Bool) {
        self._idInServer = idInServer
        self._label = label
        self._extraText = extraText
        self._checked = checked
    }
}
