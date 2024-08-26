//
//  ViewModel.swift
//  Reflectrospect
//
//  Created by Sindhu Rallabhandi on 4/12/24.
//

import Foundation
import FirebaseFirestore

class ViewModel: ObservableObject{
    @Published var moods = [MoodEntry]()
    @Published var successAlert = false

    
    
    func fetchMoods(){
        let db = Firestore.firestore()
        db.collection("moods").getDocuments() { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                return
            }
            self.moods = snapshot.documents.map{
                MoodEntry(id: $0.documentID, data: $0.data())
            }
        }
    }
    
    func getLatestMood() -> MoodEntry?{
        return moods.first
    }
    
    
    func uploadMood(moodEntry: MoodEntry){
        let db = Firestore.firestore()
        db.collection("moods").addDocument(data: moodEntry.toDict()){ [self] error in
            if let error{
                return
            }
            self.successAlert = true
        }
    }
    
    
    func deleteItems(_ indices: IndexSet){
        let mood = moods[indices.first!]
        moods.remove(atOffsets: indices)
        
        Task{
            let db = Firestore.firestore()
            try? await
            db.collection("moods").document(mood.id)
                .delete()
        }
    }

}
