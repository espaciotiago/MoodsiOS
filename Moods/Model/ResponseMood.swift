//
//  ResponseMood.swift
//  Moods
//
//  Created by Santiago Moreno on 8/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import Foundation
class ResponseMood {
    private var _mood:Mood!
    private var _event:Event!
    private var _workday:Int!
    private var _currentDate:String!
    private var _eventText:String!
    
    var mood:Mood{
        get{
            return _mood
            
        }
        set{
            _mood = newValue
            
        }
    }
    var event:Event{
        get{
            return _event
            
        }
        set{
            _event = newValue
            
        }
    }
    var workday:Int{
        get{
            return _workday
            
        }
        set{
            _workday = newValue
            
        }
    }
    var currentDate:String{
        get{
            return _currentDate
            
        }
        set{
            _currentDate = newValue
            
        }
    }
    var eventText:String{
        get{
            return _eventText
            
        }
        set{
            _eventText = newValue
            
        }
    }
    
    init(mood:Mood,event:Event,workday:Int,currentDate:String,eventText:String) {
        self._mood = mood
        self._event = event
        self._workday = workday
        self._currentDate = currentDate
        self._eventText = eventText
    }
    
    func toString()->String{
        return "Mood: \(_mood.idInServer) Event: \(_event.idInServer) Workday: \(workday) Currentdate: \(_currentDate) Eventtext: \(_eventText)"
    }
}
