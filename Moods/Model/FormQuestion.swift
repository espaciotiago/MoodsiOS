//
//  FormQuestion.swift
//  Moods
//
//  Created by Santiago Moreno on 7/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import Foundation
class FormQuestion {
    private var _idInServer:String!
    private var _category:String!
    private var _headerText:String!
    private var _selectedOption:FormOption!
    
    var idInServer:String{
        get {
            return _idInServer
        }
        set {
            _idInServer = newValue
        }
    }
    var category:String{
        get {
            return _category
        }
        set {
            _category = newValue
        }
    }
    var headerText:String{
        get {
            return _headerText
        }
        set {
            _headerText = newValue
        }
    }
    var selectedOption:FormOption{
        get {
            return _selectedOption
        }
        set {
            _selectedOption = newValue
        }
    }
    
    init(idInServer:String,category:String,headerText:String) {
        self._selectedOption = FormOption()
        self._idInServer = idInServer
        self._category = category
        self._headerText = headerText
        
    }
}
