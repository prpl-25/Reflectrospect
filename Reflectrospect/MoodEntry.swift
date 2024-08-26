//
//  MoodEntry.swift
//  Reflectrospect
//
//  Created by Sindhu Rallabhandi on 3/15/24.
//

import Foundation
import FirebaseFirestore
import CoreLocation
class MoodEntry: Identifiable{
    var id:String
    var mood:String = ""
    var emotions:String = ""
    var actionsTaken:String = ""
    var date:Date = Date()
    var location:String = ""
    var longitude:String = ""
    var latitude:String = ""
    
    static private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy, h:mm"
        return formatter
    }()
     var formattedDate: String {
        Self.dateFormatter.string(from: date)
 }
    
    init(){
        id = ""
        mood = ""
        emotions = ""
        actionsTaken = ""
        date = Date()
        location = ""
        longitude = ""
        latitude = ""
    }
    
    func toDict() -> [String : Any]{
        [
            "mood": mood,
            "emotions": emotions,
            "actionsTaken": actionsTaken,
            "date": Timestamp(date: date),
            "location": location,
            "longitude": longitude,
            "latitude": latitude,
        ]
    }
    
    init(id:String, data: [String: Any]) {
        self.id = id
        self.mood = data["mood"] as! String
        self.emotions = data["emotions"] as? String ?? ""
        self.actionsTaken =  data["actionsTaken"] as? String ?? ""
        
        if let timestamp = data["date"] as? Timestamp {
            self.date = timestamp.dateValue()
        } else{
            self.date = Date()
        }
        
        self.location =  data["location"] as? String ?? ""
        self.longitude =  data["longitude"] as? String ?? ""
        self.latitude =  data["latitude"] as? String ?? ""
    }
}
