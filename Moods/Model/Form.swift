//
//  Form.swift
//  Moods
//
//  Created by Santiago Moreno on 7/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import Foundation
class Form {
    private var _idInServer:String!
    private var _name:String!
    private var _closeDate:String!
    private var _observations:String!
    private var _openQuestionLabel:String!
    private var _sended:Bool!
    private var _alreadySended:Bool!
    private var _openQuestionNeeded:Bool!
    private var _totalQuestions:Int!
    private var _questions:[FormQuestion]!
    
    var alreadySended:Bool{
        get{
            return _alreadySended
        }
        set{
            _alreadySended = newValue
        }
    }
    
    var idInServer:String{
        get {
            return _idInServer
        }
        set {
            _idInServer = newValue
        }
    }
    var name:String{
        get {
            return _name
        }
        set {
            _name = newValue
        }
    }
    var closeDate:String{
        get {
            return _closeDate
        }
        set {
            _closeDate = newValue
        }
    }
    var observations:String{
        get {
            return _observations
        }
        set {
            _observations = newValue
        }
    }
    var openQuestionLabel:String{
        get {
            return _openQuestionLabel
        }
        set {
            _openQuestionLabel = newValue
        }
    }
    var totalQuestions:Int{
        get {
            return _totalQuestions
        }
        set {
            _totalQuestions = newValue
        }
    }
    var openQuestionNeeded:Bool{
        get{
            return _openQuestionNeeded
        }
        set{
            _openQuestionNeeded = newValue
        }
    }
    var sended:Bool{
        get{
            return _sended
        }
        set{
            _sended = newValue
        }
    }
    var questions:[FormQuestion]{
        get {
            return _questions
        }
        set {
            _questions = newValue
        }
    }
    
    init(idInServer:String, name:String, closeDate:String, observations:String, openQuestionLabel:String, totalQuestions:Int,sended:Bool,openQuestionNeeded:Bool) {
        questions = []
        self._idInServer = idInServer
        self._name = name
        self._closeDate = closeDate
        self._observations = observations
        self._openQuestionLabel = openQuestionLabel
        self._totalQuestions = totalQuestions
        self._sended = sended
        self._openQuestionNeeded = openQuestionNeeded
    }
}
