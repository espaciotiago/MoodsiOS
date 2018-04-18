//
//  MoodEventContainer.swift
//  Moods
//
//  Created by Santiago Moreno on 5/02/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import Foundation
class MoodEventContainer{
    private var _moodsEventResponseList:[MoodEventResponse]!
    private var _moodTitle:String!
    private var _resource:Int!
    
    var moodsEventResponseList:[MoodEventResponse]{
        get {
            return _moodsEventResponseList
        }
        set {
            _moodsEventResponseList = newValue
        }
    }
    
    var moodTitle:String{
        get {
            return _moodTitle
        }
        set {
            _moodTitle = newValue
        }
    }
    
    var resource:Int{
        get {
            return _resource
        }
        set {
            _resource = newValue
        }
    }
    
    init(moodsEventResponseList:[MoodEventResponse],moodTitle:String,resource:Int) {
        self._moodsEventResponseList = moodsEventResponseList
        self._moodTitle = moodTitle
        self._resource = resource
    }
    
    init() {
        self._moodsEventResponseList = [MoodEventResponse]()
        self._moodTitle = ""
        self._resource = -1
    }
}
