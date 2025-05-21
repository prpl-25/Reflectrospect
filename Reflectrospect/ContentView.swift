//
//  ContentView.swift
//  Reflectrospect
//
//  Created by Sindhu Vadapalli on 3/15/24.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import UIKit

struct ContentView: View {
   
    @State var mainPage:Bool = false
    var body: some View {
        NavigationView{
            ZStack{
                Image("bg2")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                VStack{
                    Text("Reflectrospect")
                        .font(.custom("Baskerville-Italic", size: 60))
                        .tracking(2.5)
                        .foregroundColor(.black)
                        .padding()
                    
                    Text("track your moods and regulate your emotions")
                        .font(.custom("Palatino", size: 17))
                        .foregroundColor(.black)
                        .bold()
                    Button(action: {
                        mainPage.toggle()
                    }){
                        Text("Let's Go!")
                            .foregroundColor(.white)
                    }.buttonStyle(.bordered)
                        .background(Color.black)
                        .cornerRadius(6.0)
                    
                    NavigationLink(destination: MainPageView(), isActive: $mainPage){
                        EmptyView()
                    }
                }
            }
        }
    }
}

struct MainPageView:View{
    @ObservedObject var moods = ViewModel()
    @State var addMood: Bool = false
    var body: some View{
        ZStack{
            Image("bg2")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            VStack{
                Text("Home Page")
                    .font(.custom("Baskerville", size: 35))
                    .foregroundColor(.black)
                Spacer()
                LatestMood(moods: moods)
                Spacer()
                MoodList(moods: moods)
            }
            
        }
        .onAppear(){
            moods.fetchMoods()
        }
    }
}


struct LatestMood:View {
    @ObservedObject var moods: ViewModel
    @State private var moreInfo: Bool = false
    @State private var resources: Bool = false
    @State private var latestMood = MoodEntry()
    var body: some View {
        Text("Your Latest Mood")
            .foregroundColor(.black)
            .font(.custom("Palatino", size: 20))
            .bold()
        VStack{
            if var latestMood = moods.getLatestMood(){
                Text("Mood: \(latestMood.mood)")
                    .font(.custom("Palatino", size: 20))
                    .foregroundColor(.black)
                    .bold()
                    .padding()
                Text("Date: \(latestMood.formattedDate)")
                    .font(.custom("Palatino", size: 17))
                    .foregroundColor(.black)
                Button(action: {
                    resources = true
                }){
                    Text("Need Resources?")
                        .foregroundColor(.white)
                }.buttonStyle(.bordered)
                    .background(Color.black)
                    .cornerRadius(20.0)
                    .padding()
                
                NavigationLink(destination:Resources(moods: moods), isActive:$resources){
                    EmptyView()
                }
                
            }
            else{
                Text("No past mood entries")
                    .font(.custom("Palatino", size: 17))
                    .foregroundColor(.black)
                    .bold()
            }
        }
        .frame(width: 250, height: 250)
        .background(Color.teal.opacity(0.1))
        .cornerRadius(150)
        .padding()
        .sheet(isPresented: $moreInfo){
            DetailView(moodRecord: latestMood)
                .presentationDetents([.medium])
        }
        
    }
}

struct AddMoodView: View{
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var moods: ViewModel
    @State private var moodEntry = MoodEntry()
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var locationName: String = ""
    @State private var locationTag:Bool = false
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var successAlert = false
    var body: some View{
        ZStack{
            Image("bg2")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                Text("Add a new Mood Entry")
                    .foregroundColor(.black)
                    .font(.custom("Palatino", size: 20))
                    .bold()
                VStack{
                    HStack{
                        Text("Mood")
                        Spacer()
                        TextField("Enter your current mood*", text: $moodEntry.mood)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack{
                        Text("Emotions")
                        Spacer()
                        TextField("Enter emotions you're feeling", text: $moodEntry.emotions)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack{
                        Text("Actions Taken")
                        Spacer()
                        TextField("Enter Actions Taken", text: $moodEntry.actionsTaken)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    DatePicker("", selection: $moodEntry.date, displayedComponents: [.date, .hourAndMinute])
                        .frame(width: 260)
                    
                    HStack{
                        Text("Location")
                        Spacer()
                        TextField("Enter location name",text: $moodEntry.location)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack{
                        Button(action: {
                            addMood()
                        }){
                            Text("Add Mood")
                                .foregroundColor(.white)
                        }.buttonStyle(.bordered)
                            .background(Color.black)
                            .cornerRadius(6.0)
                            .alert(alertTitle, isPresented: $showingAlert) {
                                Button("OK", role: .cancel) {
                                    showingAlert = false
                                }
                            } message: {
                                Text(alertMessage)
                            }
                            .alert("Success", isPresented: $moods.successAlert) {
                                Button("OK", role: .cancel) {
                                    dismiss()
                                    successAlert = false
                                }
                            } message: {
                                Text("\(moodEntry.mood) was added to the database")
                            }
                    }
                }
                .frame(width: 350, height: 300)
                .background(Color.white.opacity(0.5))
                .cornerRadius(5)
                .padding()
            }
        }
    }
    
    private func isFormValid() -> Bool{
        if moodEntry.mood.isEmpty {
            showAlert(title: "Name Error", message: "Mood name should be entered")
            return false
        }
        return true
    }
    
    private func addMood(){
        if isFormValid(){
            moods.uploadMood(moodEntry: moodEntry)
            }
        }

    private func showAlert(title: String, message: String){
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

struct MoodList: View{
    @ObservedObject var moods: ViewModel
    var body: some View{
        Text("Past Mood Records")
            .foregroundColor(.black)
            .font(.custom("Palatino", size: 20))
            .bold()
        List{
            ForEach(moods.moods){mood in
                NavigationLink(destination: DetailView(moodRecord: mood)){
                    HStack{
                        Text("Mood Entry: \(mood.mood)")
                    }
                }
            }
            .onDelete(perform: moods.deleteItems(_:))
            .frame(width: 250, height: 30)
                .foregroundColor(.black)
                .bold()
        }
        .background(Color.white.opacity(0.3))
        .scrollContentBackground(.hidden)
        .cornerRadius(8)
        .padding()
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                NavigationLink{
                    AddMoodView(moods: moods)
                } label: {
                    Label("Add New", systemImage: "plus")
                        .labelStyle(.titleAndIcon)
                }
            }
        }
    }
}

struct Resources:View {
    @State private var city: String = ""
    @ObservedObject var moods: ViewModel
    @State private var viewMap: Bool = false
    @State private var getArticles: Bool = false
    var body: some View {
        ZStack{
            Image("bg2")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            VStack{
                Text("Resources")
                    .font(.custom("Baskerville", size: 35))
                    .foregroundColor(.black)
                    .padding()
                    .frame(width: 350, height: 150)
                VStack{
                    Text("Search near you: ")
                        .foregroundColor(.black)
                        .font(.custom("Palatino", size: 20))
                        .bold()
                    
                    Text("Parks/therapy/hiking trails, etc")
                        .foregroundColor(.black)
                        .font(.custom("Palatino", size: 17))
                        .bold()
                    
                }
                VStack{
                    HStack{
                        Text("City Name")
                            .foregroundColor(.black)
                            .font(.custom("Palatino", size: 20))
                            .bold()
                        Spacer()
                        TextField("Enter your city", text: $city)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding()
                    Button(action: {
                        viewMap = true
                    }){
                        Text("Search")
                            .foregroundColor(.white)
                    }.buttonStyle(.bordered)
                        .background(Color.black)
                        .cornerRadius(6.0)
                }
                .frame(width: 350, height: 100)
                
                HStack{
                    Text("Wanna educate yourself?")
                        .foregroundColor(.black)
                        .font(.custom("Palatino", size: 20))
                        .bold()
                    
                    Button(action: {
                        getArticles = true
                    }){
                        Text("Get Articles")
                            .foregroundColor(.white)
                    }.buttonStyle(.bordered)
                        .background(Color.black)
                        .cornerRadius(6.0)
                }
                .frame(width: 350, height: 250)
                NavigationLink(destination: APIView(moods: moods), isActive: $getArticles){
                    EmptyView()
                }
                
                
                NavigationLink(destination: MapView(city: city), isActive: $viewMap){
                    EmptyView()
                }
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                NavigationLink{
                    MainPageView(moods: moods)
                } label: {
                    Label("Go back to Home", systemImage: "house")
                        .labelStyle(.titleAndIcon)
                }
            }
        }
    }
    
}

struct Location:Identifiable{
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}
struct MapView: View {
    @State private var cityCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    
    @State var city: String
    
    
    private static let defaultLocation = CLLocationCoordinate2D()
    
    @State private var region = MKCoordinateRegion(
        center: defaultLocation,
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    
    @State private var markers = [Location(name: "", coordinate: defaultLocation)]
    @State private var searchText = ""
    var body: some View{
        VStack{
            ZStack(alignment: .bottom){
                Map(coordinateRegion: $region,
                    interactionModes: .all,
                    annotationItems: markers
                ){ location in
                    MapMarker(coordinate: location.coordinate)
                }
                .ignoresSafeArea()
                searchBar
            }
        }
        .onAppear{
            forwardGeocoding(addressStr: city)
            
        }
    }
    
    private var searchBar: some View{
        HStack{
            Button{
                let searchRequest = MKLocalSearch.Request()
                searchRequest.naturalLanguageQuery = searchText
                searchRequest.region = region
                
                MKLocalSearch(request: searchRequest).start{response,
                    error in
                    guard let response = response else{
                        print("Error: \(error?.localizedDescription ?? "Unknown error").")
                        return
                    }
                    region = response.boundingRegion
                    markers = response.mapItems.map {item in
                        Location(
                            name: item.name ?? "",
                            coordinate: item.placemark.coordinate
                        )
                    }
                }
            }label:{
                Image(systemName: "location.magnifyingglass")
                    .resizable()
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 12)
            }
            TextField("Search e.g. Mill Cue Club", text: $searchText)
                .foregroundColor(.white)
        }
        .padding()
        .background{
            RoundedRectangle(cornerRadius: 8.0)
                .foregroundColor(.black)
        }
        .padding()
    }
    
    func forwardGeocoding(addressStr: String)
    {
        let geoCoder = CLGeocoder();
        let addressString = addressStr
        CLGeocoder().geocodeAddressString(addressString, completionHandler:
                                            {(placemarks, error) in
            
            if error != nil {
                print("Geocode failed: \(error!.localizedDescription)")
            } else if placemarks!.count > 0 {
                let placemark = placemarks![0]
                let location = placemark.location
                let coords = location!.coordinate
                self.cityCoordinate = coords
                
                DispatchQueue.main.async
                    {
                        region.center = coords
                        markers[0].name = placemark.locality!
                        markers[0].coordinate = coords
                    }
            }
        })
    }
}

struct DetailView: View{
    @State var moodRecord: MoodEntry
    var body: some View{
        ZStack{
            Image("bg2")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            VStack{
                Text("Mood: \(moodRecord.mood)")
                    .font(.custom("Palatino", size: 37))
                    .bold()
                Text("Emotions: \(moodRecord.emotions)")
                    .font(.custom("Palatino", size: 20))
                    .bold()
                    .padding()
                Text("Actions Taken: \(moodRecord.actionsTaken)")
                    .font(.custom("Palatino", size: 20))
                    .padding()
                Text("Date:\(moodRecord.formattedDate)")
                    .font(.custom("Palatino", size: 20))
                    .padding()
                Text("Location: \(moodRecord.location)")
                    .font(.custom("Palatino", size: 20))
                    .padding()
            }
        }
    }
}

struct APIView: View {
    @ObservedObject var moods: ViewModel
    let categories = ["Mental Health", "Happiness", "Coping Mechanisms"]
    @State private var category: String = ""
    @State private var articlesList = [ListArticles]()
    @State private var getArticles: Bool = false
    var body: some View {
        ZStack{
            Image("bg2")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            VStack{
                HStack{
                    Text("Choose a category:")
                    Picker("", selection: $category){
                        ForEach(categories, id:\.self){category in
                            Text(category)
                        }
                        .foregroundColor(.teal)
                    }
                }
                Button(action: {
                    let apiImp = APIimplementation(category: category)
                    apiImp.fetchArticles{
                        fetchedArticles in
                        self.articlesList = fetchedArticles
                        getArticles = true
                    }
                }){
                    Text("Articles?")
                        .foregroundColor(.white)
                }.buttonStyle(.bordered)
                    .background(Color.black)
                    .cornerRadius(6.0)

                
                if getArticles{
                    let url = URL(string: "https://www.bbc.co.uk/news/uk-wales-68773444")
                    List{
                        ForEach(articlesList){article in
                            VStack{
                                Text("Title:  \(article.title)")
                                Button(action: {
                                    openURL(urlString: article.url.absoluteString)
                                    
                                }){
                                    Text("Read Article")
                                }
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                        }
                    }
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(8)
                    .padding()
                    .frame(width: 400, height: 600)
                }
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    NavigationLink{
                        MainPageView(moods: moods)
                    } label: {
                        Label("Go back to Home", systemImage: "house")
                            .labelStyle(.titleAndIcon)
                    }
                }
            }
        }
    }
    
    func openURL(urlString: String){
        UIApplication.shared.open(URL(string: urlString)! as URL)
    }
}


#Preview {
    ContentView()
}
