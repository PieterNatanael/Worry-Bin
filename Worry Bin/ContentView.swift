//
//  ContentView.swift
//  Worry Bin
//
//  Created by Pieter Yoshua Natanael on 16/04/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var showAd = false
    @State private var showExplain = false
    @State private var showDeleteConfirmation = false
    @State private var selectedWorry: Worry?

    
    @State private var worries: [Worry] = []
    @State private var clapSoundPlayer: AVAudioPlayer?
    @State private var defaults = UserDefaults.standard // Add UserDefaults
    @StateObject private var viewModel = WorryViewModel()
       @State private var newWorryText = ""

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    // Add the save function for data persistence
    func save() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(worries) {
            defaults.set(encoded, forKey: "SavedWorries")
        }
    }

    // Add the load function for data persistence
    func load() {
        let decoder = JSONDecoder()
        if let data = defaults.data(forKey: "SavedWorries") {
            if let loadedWorries = try? decoder.decode([Worry].self, from: data) {
                worries = loadedWorries
            }
        }
    }

        // Modify the addWorry function to save data
        func addWorry() {
            let newWorry = Worry(text: newWorryText)
            worries.append(newWorry)
            newWorryText = ""

            save() // Save data after adding a worry

            playClapSound()
            showMessage(title: "Thank You!", message: "Thank you for sharing your worry.")
        }

        // Modify the deleteWorry function to save data
    func deleteWorry(atOffsets offsets: IndexSet) {
        worries.remove(atOffsets: offsets)
        save() // Save data after deleting a worry
    }

 

    
    func playClapSound() {
        if let soundURL = Bundle.main.url(forResource: "clap", withExtension: "mp3") {
            do {
                // Initialize the AVAudioPlayer with the clap sound URL
                clapSoundPlayer = try AVAudioPlayer(contentsOf: soundURL)
                clapSoundPlayer?.play() // Play the clap sound
            } catch {
                print("Error loading clap sound file: \(error.localizedDescription)")
            }
        } else {
            print("Clap sound file not found.")
        }
    }


    func showMessage(title: String, message: String) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            windowScene.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
   


    func toggleRealized(for worry: Worry) {
        if let index = worries.firstIndex(where: { $0.id == worry.id }) {
            worries[index].realized.toggle()
        }
    }




    var body: some View {
        VStack {
            HStack {
                
                 
               
                    Spacer()
                    Button(action: {
                        showExplain = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)))
                            .padding()
                    }
                
            }
            Spacer()
            
            HStack{
                Text("Worry Bin")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
            }

            TextField("Enter your worry", text: $newWorryText)
                .padding()

            Button(action: addWorry) {
                Text("Save Worry")
                    .padding()
                    .font(.caption.bold())
                    .foregroundColor(.black)
                    .background(Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)))
                    .cornerRadius(8)
            }
            .padding()

            List {
                ForEach(worries) { worry in
                    VStack(alignment: .leading) {
                        Text(worry.text)
                        HStack {
                            Text("Added: \(worry.timestamp, formatter: dateFormatter)")
                            Spacer()
                            Text("\(worry.daysAgo) days ago")
                            Button(action: {
                                toggleRealized(for: worry)
                            }) {
                                Image(systemName: worry.realized ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(worry.realized ? .green : .primary)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            Button(action: {
                                selectedWorry = worry
                                showDeleteConfirmation = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .foregroundColor(worry.realized ? .green : .red)
                    }
                }
                .onDelete(perform: deleteWorry)
            }
            .listStyle(PlainListStyle())
        }
        .onAppear {
            load()}
        
        .sheet(isPresented: $showAd) {
            ShowAdView(onConfirm: {
                showAd = false
            })
        }
        .sheet(isPresented: $showExplain) {
            ShowExplainView(onConfirm: {
                showExplain = false
            })
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Worry"),
                message: Text("Are you sure you want to delete this worry forever?"),
                primaryButton: .destructive(Text("Yes")) {
                    if let selectedWorry = selectedWorry {
                        if let index = worries.firstIndex(where: { $0.id == selectedWorry.id }) {
                            worries.remove(at: index)
                        }
                    }
                    selectedWorry = nil
                    save()
                           playClapSound()
                },
                secondaryButton: .cancel(Text("No")) {
                    selectedWorry = nil
                }
            )
        }
    }
}

struct Worry: Identifiable, Codable {
    var id = UUID()
    var text: String
    var realized = false
    var timestamp = Date()
    
    var daysAgo: Int {
        Calendar.current.dateComponents([.day], from: timestamp, to: Date()).day ?? 0
    }
}


// MARK: - Ad View
struct ShowAdView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Ads")
                        .font(.largeTitle.bold())
                    Spacer()
                }
                ZStack {
                    Image("threedollar")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(25)
                        .clipped()
                        .onTapGesture {
                            if let url = URL(string: "https://b33.biz/three-dollar/") {
                                UIApplication.shared.open(url)
                            }
                        }
                }
                // App Cards
                VStack {
                    Divider().background(Color.gray)
                    AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                    Divider().background(Color.gray)
                    // Add more AppCardViews here if needed
                    // App Data
                 
                    
                    AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch, for time-sensitive tasks.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, stay motivated.", appURL: "https://apps.apple.com/id/app/temptationtrack/id6471236988")
                    Divider().background(Color.gray)
                
                }
                Spacer()

                // Close Button
                Button("Close") {
                    // Perform confirmation action
                    onConfirm()
                }
                .font(.title)
                .padding()
                .cornerRadius(25.0)
                .padding()
            }
            .padding()
            .cornerRadius(15.0)
            .padding()
        }
    }
}

// MARK: - App Card View
struct AppCardView: View {
    var imageName: String
    var appName: String
    var appDescription: String
    var appURL: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(7)
            
            VStack(alignment: .leading) {
                Text(appName)
                    .font(.title3)
                Text(appDescription)
                    .font(.caption)
            }
            .frame(alignment: .leading)
            
            Spacer()
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Try")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Explain View
struct ShowExplainView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
               HStack{
                   Text("Ads & App Functionality")
                       .font(.title.bold())
                   Spacer()
               }
              
                //ads
                VStack {
                    HStack {
                        Text("Ads")
                            .font(.largeTitle.bold())
                        Spacer()
                    }
                    ZStack {
                        Image("threedollar")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(25)
                            .clipped()
                            .onTapGesture {
                                if let url = URL(string: "https://b33.biz/three-dollar/") {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                    // App Cards
                    VStack {
                        Divider().background(Color.gray)
                        AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                        Divider().background(Color.gray)
                        // Add more AppCardViews here if needed
                        // App Data
                     
                        
                        AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch, for time-sensitive tasks.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, stay motivated.", appURL: "https://apps.apple.com/id/app/temptationtrack/id6471236988")
                        Divider().background(Color.gray)
                    
                    }
                    Spacer()

                   
                   
                }
                .padding()
                .cornerRadius(15.0)
                .padding()
                
                //ads end
                
                
                HStack{
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }
               
               Text("""
               •Users can enter their worries into a text field and save them.
               •Saved worries are displayed in a list with details such as the date added and how many days ago they were added.
               •Each worry in the list has a "checkmark" button that users can tap to mark the worry as realized (if it has come true).
               •Users can delete worries by tapping the "trash" button next to each worry, with a confirmation dialog to ensure they want to delete it permanently.
               •The app automatically calculates and displays the number of days since each worry was added.
               •We do not collect data, so there's no need to worry
               """)
               .font(.title3)
               .multilineTextAlignment(.leading)
               .padding()
               
               Spacer()
                
                HStack {
                    Text("Worry Bin is developed by Three Dollar.")
                        .font(.title3.bold())
                    Spacer()
                }

               Button("Close") {
                   // Perform confirmation action
                   onConfirm()
               }
               .font(.title)
               .padding()
               .cornerRadius(25.0)
               .padding()
           }
           .padding()
           .cornerRadius(15.0)
           .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/*
//gagal untuk persist yg delete

import SwiftUI
import AVFoundation


struct ContentView: View {
    @State private var showAd = false
    @State private var showExplain = false
    @State private var showDeleteConfirmation = false
    @State private var selectedWorry: Worry?

    @State private var newWorryText = ""
    @State private var worries: [Worry] = []
    @State private var clapSoundPlayer: AVAudioPlayer?

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    init() {
        loadWorries()
    }


    // Load saved worries from UserDefaults
    func loadWorries() {
        if let savedWorries = UserDefaults.standard.data(forKey: "SavedWorries") {
            let decoder = JSONDecoder()
            if let decodedWorries = try? decoder.decode([Worry].self, from: savedWorries) {
                worries = decodedWorries
            } else {
                // Handle decoding failure if needed
                print("Error decoding saved worries.")
            }
        } else {
            // Handle no saved data if needed
            print("No saved worries found.")
        }
    }

    
    // Save worries array to UserDefaults
    // Consolidated saveWorries function
    // Consolidated saveWorries function
    func saveWorries() {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(worries)
            UserDefaults.standard.set(encoded, forKey: "SavedWorries")
        } catch {
            print("Error encoding worries: \(error.localizedDescription)")
        }
    }


    func playClapSound() {
        if let soundURL = Bundle.main.url(forResource: "clap", withExtension: "mp3") {
            do {
                // Initialize the AVAudioPlayer with the clap sound URL
                clapSoundPlayer = try AVAudioPlayer(contentsOf: soundURL)
                clapSoundPlayer?.play() // Play the clap sound
            } catch {
                print("Error loading clap sound file: \(error.localizedDescription)")
            }
        } else {
            print("Clap sound file not found.")
        }
    }


    func showMessage(title: String, message: String) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            windowScene.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func addWorry() {
        let newWorry = Worry(text: newWorryText)
        worries.append(newWorry)
        newWorryText = ""

        playClapSound()
        showMessage(title: "Thank You!", message: "Thank you for sharing your worry.")
        
        saveWorries() // Save the worries after adding a new one
    }

    func deleteWorry(atOffsets offsets: IndexSet) {
        if let index = offsets.first {
            selectedWorry = worries[index]

            // Debugging message
            print("Selected worry for deletion: \(selectedWorry?.text ?? "Unknown")")

            worries.remove(atOffsets: offsets)
            
            // Check if selectedWorry matches the one removed
            if selectedWorry != nil && selectedWorry?.id == worries[index].id {
                selectedWorry = nil
            }

            saveWorries() // Save the updated worries array after deletion
            playClapSound() // Play the clap sound

            // Debugging message
            print("Deleted worry from array.")
        }
    }





    func toggleRealized(for worry: Worry) {
        if let index = worries.firstIndex(where: { $0.id == worry.id }) {
            worries[index].realized.toggle()
        }
    }

   


    var body: some View {
        VStack {
            HStack {
                
                 
               
                    Spacer()
                    Button(action: {
                        showExplain = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)))
                            .padding()
                    }
                
            }
            Spacer()
            
            HStack{
                Text("Worry Bin")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
            }

            TextField("Enter your worry", text: $newWorryText)
                .padding()

            Button(action: addWorry) {
                Text("Save Worry")
                    .padding()
                    .font(.caption.bold())
                    .foregroundColor(.black)
                    .background(Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)))
                    .cornerRadius(8)
            }
            .padding()

            List {
                ForEach(worries) { worry in
                    VStack(alignment: .leading) {
                        Text(worry.text)
                        HStack {
                            Text("Added: \(worry.timestamp, formatter: dateFormatter)")
                            Spacer()
                            Text("\(worry.daysAgo) days ago")
                            Button(action: {
                                toggleRealized(for: worry)
                            }) {
                                Image(systemName: worry.realized ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(worry.realized ? .green : .primary)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            Button(action: {
                                selectedWorry = worry
                                showDeleteConfirmation = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .foregroundColor(worry.realized ? .green : .red)
                    }
                }
                .onDelete(perform: deleteWorry)
            }
            .listStyle(PlainListStyle())
        }
        .onAppear(perform: loadWorries)

        
       
        .sheet(isPresented: $showExplain) {
            ShowExplainView(onConfirm: {
                showExplain = false
            })
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Worry"),
                message: Text("Are you sure you want to delete this worry forever?"),
                primaryButton: .destructive(Text("Yes")) {
                    if let selectedWorry = selectedWorry {
                        if let index = worries.firstIndex(where: { $0.id == selectedWorry.id }) {
                            worries.remove(at: index)
                        }
                    }
                    selectedWorry = nil
                   
                           playClapSound()
                },
                secondaryButton: .cancel(Text("No")) {
                    selectedWorry = nil
                }

            )
        }
    }
}

struct Worry: Identifiable, Codable {
    var id = UUID()
    var text: String
    var realized = false
    var timestamp = Date()
    
    var daysAgo: Int {
        Calendar.current.dateComponents([.day], from: timestamp, to: Date()).day ?? 0
    }
}




// MARK: - Ad View
struct ShowAdView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Ads")
                        .font(.largeTitle.bold())
                    Spacer()
                }
                ZStack {
                    Image("threedollar")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(25)
                        .clipped()
                        .onTapGesture {
                            if let url = URL(string: "https://b33.biz/three-dollar/") {
                                UIApplication.shared.open(url)
                            }
                        }
                }
                // App Cards
                VStack {
                    Divider().background(Color.gray)
                    AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                    Divider().background(Color.gray)
                    // Add more AppCardViews here if needed
                    // App Data
                 
                    
                    AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch, for time-sensitive tasks.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, stay motivated.", appURL: "https://apps.apple.com/id/app/temptationtrack/id6471236988")
                    Divider().background(Color.gray)
                
                }
                Spacer()

                // Close Button
                Button("Close") {
                    // Perform confirmation action
                    onConfirm()
                }
                .font(.title)
                .padding()
                .cornerRadius(25.0)
                .padding()
            }
            .padding()
            .cornerRadius(15.0)
            .padding()
        }
    }
}

// MARK: - App Card View
struct AppCardView: View {
    var imageName: String
    var appName: String
    var appDescription: String
    var appURL: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(7)
            
            VStack(alignment: .leading) {
                Text(appName)
                    .font(.title3)
                Text(appDescription)
                    .font(.caption)
            }
            .frame(alignment: .leading)
            
            Spacer()
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Try")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Explain View
struct ShowExplainView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
               HStack{
                   Text("Ads & App Functionality")
                       .font(.title.bold())
                   Spacer()
               }
              
                //ads
                VStack {
                    HStack {
                        Text("Ads")
                            .font(.largeTitle.bold())
                        Spacer()
                    }
                    ZStack {
                        Image("threedollar")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(25)
                            .clipped()
                            .onTapGesture {
                                if let url = URL(string: "https://b33.biz/three-dollar/") {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                    // App Cards
                    VStack {
                        Divider().background(Color.gray)
                        AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                        Divider().background(Color.gray)
                        // Add more AppCardViews here if needed
                        // App Data
                     
                        
                        AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch, for time-sensitive tasks.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, stay motivated.", appURL: "https://apps.apple.com/id/app/temptationtrack/id6471236988")
                        Divider().background(Color.gray)
                    
                    }
                    Spacer()

                   
                   
                }
                .padding()
                .cornerRadius(15.0)
                .padding()
                
                //ads end
                
                
                HStack{
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }
               
               Text("""
               •Users can enter their worries into a text field and save them.
               •Saved worries are displayed in a list with details such as the date added and how many days ago they were added.
               •Each worry in the list has a "checkmark" button that users can tap to mark the worry as realized (if it has come true).
               •Users can delete worries by tapping the "trash" button next to each worry, with a confirmation dialog to ensure they want to delete it permanently.
               •The app automatically calculates and displays the number of days since each worry was added.
               •We do not collect data, so there's no need to worry
               """)
               .font(.title3)
               .multilineTextAlignment(.leading)
               .padding()
               
               Spacer()
                
                HStack {
                    Text("Worry Bin is developed by Three Dollar.")
                        .font(.title3.bold())
                    Spacer()
                }

               Button("Close") {
                   // Perform confirmation action
                   onConfirm()
               }
               .font(.title)
               .padding()
               .cornerRadius(25.0)
               .padding()
           }
           .padding()
           .cornerRadius(15.0)
           .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

*/

/*
//bagus namun mau add data persistent agar data tidak hilang kalau app ditutup

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var showAd = false
    @State private var showExplain = false
    @State private var showDeleteConfirmation = false
    @State private var selectedWorry: Worry?

    @State private var newWorryText = ""
    @State private var worries: [Worry] = []
    @State private var clapSoundPlayer: AVAudioPlayer?

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    
    func playClapSound() {
        if let soundURL = Bundle.main.url(forResource: "clap", withExtension: "mp3") {
            do {
                // Initialize the AVAudioPlayer with the clap sound URL
                clapSoundPlayer = try AVAudioPlayer(contentsOf: soundURL)
                clapSoundPlayer?.play() // Play the clap sound
            } catch {
                print("Error loading clap sound file: \(error.localizedDescription)")
            }
        } else {
            print("Clap sound file not found.")
        }
    }


    func showMessage(title: String, message: String) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            windowScene.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func addWorry() {
           let newWorry = Worry(text: newWorryText)
           worries.append(newWorry)
           newWorryText = ""

           playClapSound()
           showMessage(title: "Thank You!", message: "Thank you for sharing your worry.")
       }


    func toggleRealized(for worry: Worry) {
        if let index = worries.firstIndex(where: { $0.id == worry.id }) {
            worries[index].realized.toggle()
        }
    }

    func deleteWorry(atOffsets offsets: IndexSet) {
        worries.remove(atOffsets: offsets)
      
    }


    var body: some View {
        VStack {
            HStack {
                
                 
               
                    Spacer()
                    Button(action: {
                        showExplain = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)))
                            .padding()
                    }
                
            }
            Spacer()
            
            HStack{
                Text("Worry Bin")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
            }

            TextField("Enter your worry", text: $newWorryText)
                .padding()

            Button(action: addWorry) {
                Text("Save Worry")
                    .padding()
                    .font(.caption.bold())
                    .foregroundColor(.black)
                    .background(Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)))
                    .cornerRadius(8)
            }
            .padding()

            List {
                ForEach(worries) { worry in
                    VStack(alignment: .leading) {
                        Text(worry.text)
                        HStack {
                            Text("Added: \(worry.timestamp, formatter: dateFormatter)")
                            Spacer()
                            Text("\(worry.daysAgo) days ago")
                            Button(action: {
                                toggleRealized(for: worry)
                            }) {
                                Image(systemName: worry.realized ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(worry.realized ? .green : .primary)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            Button(action: {
                                selectedWorry = worry
                                showDeleteConfirmation = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .foregroundColor(worry.realized ? .green : .red)
                    }
                }
                .onDelete(perform: deleteWorry)
            }
            .listStyle(PlainListStyle())
        }
        .sheet(isPresented: $showAd) {
            ShowAdView(onConfirm: {
                showAd = false
            })
        }
        .sheet(isPresented: $showExplain) {
            ShowExplainView(onConfirm: {
                showExplain = false
            })
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Worry"),
                message: Text("Are you sure you want to delete this worry forever?"),
                primaryButton: .destructive(Text("Yes")) {
                    if let selectedWorry = selectedWorry {
                        if let index = worries.firstIndex(where: { $0.id == selectedWorry.id }) {
                            worries.remove(at: index)
                        }
                    }
                    selectedWorry = nil
                   
                           playClapSound()
                },
                secondaryButton: .cancel(Text("No")) {
                    selectedWorry = nil
                }
            )
        }
    }
}

struct Worry: Identifiable {
    let id = UUID()
    var text: String
    var realized = false
    var timestamp = Date()
    
    var daysAgo: Int {
        Calendar.current.dateComponents([.day], from: timestamp, to: Date()).day ?? 0
    }
}



// MARK: - Ad View
struct ShowAdView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Ads")
                        .font(.largeTitle.bold())
                    Spacer()
                }
                ZStack {
                    Image("threedollar")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(25)
                        .clipped()
                        .onTapGesture {
                            if let url = URL(string: "https://b33.biz/three-dollar/") {
                                UIApplication.shared.open(url)
                            }
                        }
                }
                // App Cards
                VStack {
                    Divider().background(Color.gray)
                    AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                    Divider().background(Color.gray)
                    // Add more AppCardViews here if needed
                    // App Data
                 
                    
                    AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch, for time-sensitive tasks.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, stay motivated.", appURL: "https://apps.apple.com/id/app/temptationtrack/id6471236988")
                    Divider().background(Color.gray)
                
                }
                Spacer()

                // Close Button
                Button("Close") {
                    // Perform confirmation action
                    onConfirm()
                }
                .font(.title)
                .padding()
                .cornerRadius(25.0)
                .padding()
            }
            .padding()
            .cornerRadius(15.0)
            .padding()
        }
    }
}

// MARK: - App Card View
struct AppCardView: View {
    var imageName: String
    var appName: String
    var appDescription: String
    var appURL: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(7)
            
            VStack(alignment: .leading) {
                Text(appName)
                    .font(.title3)
                Text(appDescription)
                    .font(.caption)
            }
            .frame(alignment: .leading)
            
            Spacer()
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Try")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Explain View
struct ShowExplainView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
               HStack{
                   Text("Ads & App Functionality")
                       .font(.title.bold())
                   Spacer()
               }
              
                //ads
                VStack {
                    HStack {
                        Text("Ads")
                            .font(.largeTitle.bold())
                        Spacer()
                    }
                    ZStack {
                        Image("threedollar")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(25)
                            .clipped()
                            .onTapGesture {
                                if let url = URL(string: "https://b33.biz/three-dollar/") {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                    // App Cards
                    VStack {
                        Divider().background(Color.gray)
                        AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                        Divider().background(Color.gray)
                        // Add more AppCardViews here if needed
                        // App Data
                     
                        
                        AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch, for time-sensitive tasks.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, stay motivated.", appURL: "https://apps.apple.com/id/app/temptationtrack/id6471236988")
                        Divider().background(Color.gray)
                    
                    }
                    Spacer()

                   
                   
                }
                .padding()
                .cornerRadius(15.0)
                .padding()
                
                //ads end
                
                
                HStack{
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }
               
               Text("""
               •Users can enter their worries into a text field and save them.
               •Saved worries are displayed in a list with details such as the date added and how many days ago they were added.
               •Each worry in the list has a "checkmark" button that users can tap to mark the worry as realized (if it has come true).
               •Users can delete worries by tapping the "trash" button next to each worry, with a confirmation dialog to ensure they want to delete it permanently.
               •The app automatically calculates and displays the number of days since each worry was added.
               •We do not collect data, so there's no need to worry
               """)
               .font(.title3)
               .multilineTextAlignment(.leading)
               .padding()
               
               Spacer()
                
                HStack {
                    Text("Worry Bin is developed by Three Dollar.")
                        .font(.title3.bold())
                    Spacer()
                }

               Button("Close") {
                   // Perform confirmation action
                   onConfirm()
               }
               .font(.title)
               .padding()
               .cornerRadius(25.0)
               .padding()
           }
           .padding()
           .cornerRadius(15.0)
           .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


*/


/*
//udah bagus namun mau ada add clap dan showing screen thanks

import SwiftUI

struct ContentView: View {
    @State private var showAd = false
    @State private var showExplain = false
    @State private var showDeleteConfirmation = false
    @State private var selectedWorry: Worry?

    @State private var newWorryText = ""
    @State private var worries: [Worry] = []

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    func addWorry() {
        let newWorry = Worry(text: newWorryText)
        worries.append(newWorry)
        newWorryText = ""
    }

    func toggleRealized(for worry: Worry) {
        if let index = worries.firstIndex(where: { $0.id == worry.id }) {
            worries[index].realized.toggle()
        }
    }

    func deleteWorry(atOffsets offsets: IndexSet) {
        worries.remove(atOffsets: offsets)
    }

    var body: some View {
        VStack {
            HStack {
                
                 
               
                    Spacer()
                    Button(action: {
                        showExplain = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)))
                            .padding()
                    }
                
            }
            Spacer()
            
            HStack{
                Text("Worry Bin")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
            }

            TextField("Enter your worry", text: $newWorryText)
                .padding()

            Button(action: addWorry) {
                Text("Save Worry")
                    .padding()
                    .font(.title3.bold())
                    .foregroundColor(.black)
                    .background(Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)))
                    .cornerRadius(8)
            }
            .padding()

            List {
                ForEach(worries) { worry in
                    VStack(alignment: .leading) {
                        Text(worry.text)
                        HStack {
                            Text("Added: \(worry.timestamp, formatter: dateFormatter)")
                            Spacer()
                            Text("\(worry.daysAgo) days ago")
                            Button(action: {
                                toggleRealized(for: worry)
                            }) {
                                Image(systemName: worry.realized ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(worry.realized ? .green : .primary)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            Button(action: {
                                selectedWorry = worry
                                showDeleteConfirmation = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .foregroundColor(worry.realized ? .green : .red)
                    }
                }
                .onDelete(perform: deleteWorry)
            }
            .listStyle(PlainListStyle())
        }
        .sheet(isPresented: $showAd) {
            ShowAdView(onConfirm: {
                showAd = false
            })
        }
        .sheet(isPresented: $showExplain) {
            ShowExplainView(onConfirm: {
                showExplain = false
            })
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Worry"),
                message: Text("Are you sure you want to delete this worry forever?"),
                primaryButton: .destructive(Text("Yes")) {
                    if let selectedWorry = selectedWorry {
                        if let index = worries.firstIndex(where: { $0.id == selectedWorry.id }) {
                            worries.remove(at: index)
                        }
                    }
                    selectedWorry = nil
                },
                secondaryButton: .cancel(Text("No")) {
                    selectedWorry = nil
                }
            )
        }
    }
}

struct Worry: Identifiable {
    let id = UUID()
    var text: String
    var realized = false
    var timestamp = Date()
    
    var daysAgo: Int {
        Calendar.current.dateComponents([.day], from: timestamp, to: Date()).day ?? 0
    }
}



// MARK: - Ad View
struct ShowAdView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Ads")
                        .font(.largeTitle.bold())
                    Spacer()
                }
                ZStack {
                    Image("threedollar")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(25)
                        .clipped()
                        .onTapGesture {
                            if let url = URL(string: "https://b33.biz/three-dollar/") {
                                UIApplication.shared.open(url)
                            }
                        }
                }
                // App Cards
                VStack {
                    Divider().background(Color.gray)
                    AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                    Divider().background(Color.gray)
                    // Add more AppCardViews here if needed
                    // App Data
                 
                    
                    AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch, for time-sensitive tasks.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, stay motivated.", appURL: "https://apps.apple.com/id/app/temptationtrack/id6471236988")
                    Divider().background(Color.gray)
                
                }
                Spacer()

                // Close Button
                Button("Close") {
                    // Perform confirmation action
                    onConfirm()
                }
                .font(.title)
                .padding()
                .cornerRadius(25.0)
                .padding()
            }
            .padding()
            .cornerRadius(15.0)
            .padding()
        }
    }
}

// MARK: - App Card View
struct AppCardView: View {
    var imageName: String
    var appName: String
    var appDescription: String
    var appURL: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(7)
            
            VStack(alignment: .leading) {
                Text(appName)
                    .font(.title3)
                Text(appDescription)
                    .font(.caption)
            }
            .frame(alignment: .leading)
            
            Spacer()
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Try")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Explain View
struct ShowExplainView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
               HStack{
                   Text("Ads & App Functionality")
                       .font(.title.bold())
                   Spacer()
               }
              
                //ads
                VStack {
                    HStack {
                        Text("Ads")
                            .font(.largeTitle.bold())
                        Spacer()
                    }
                    ZStack {
                        Image("threedollar")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(25)
                            .clipped()
                            .onTapGesture {
                                if let url = URL(string: "https://b33.biz/three-dollar/") {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                    // App Cards
                    VStack {
                        Divider().background(Color.gray)
                        AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                        Divider().background(Color.gray)
                        // Add more AppCardViews here if needed
                        // App Data
                     
                        
                        AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch, for time-sensitive tasks.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, stay motivated.", appURL: "https://apps.apple.com/id/app/temptationtrack/id6471236988")
                        Divider().background(Color.gray)
                    
                    }
                    Spacer()

                   
                   
                }
                .padding()
                .cornerRadius(15.0)
                .padding()
                
                //ads end
                
                
                HStack{
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }
               
               Text("""
               •Users can enter their worries into a text field and save them.
               •Saved worries are displayed in a list with details such as the date added and how many days ago they were added.
               •Each worry in the list has a "checkmark" button that users can tap to mark the worry as realized (if it has come true).
               •Users can delete worries by tapping the "trash" button next to each worry, with a confirmation dialog to ensure they want to delete it permanently.
               •The app automatically calculates and displays the number of days since each worry was added.
               •We do not collect data, so there's no need to worry
               """)
               .font(.title3)
               .multilineTextAlignment(.leading)
               .padding()
               
               Spacer()
                
                HStack {
                    Text("Worry Bin is developed by Three Dollar.")
                        .font(.title3.bold())
                    Spacer()
                }

               Button("Close") {
                   // Perform confirmation action
                   onConfirm()
               }
               .font(.title)
               .padding()
               .cornerRadius(25.0)
               .padding()
           }
           .padding()
           .cornerRadius(15.0)
           .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

*/



/*
import SwiftUI

struct ContentView: View {
    @State private var worries: [Worry] = []
    @State private var newWorryText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your worry", text: $newWorryText)
                    .padding()
                
                Button(action: addWorry) {
                    Text("Save Worry")
                }
                .padding()
                
                List {
                    ForEach(worries) { worry in
                        VStack(alignment: .leading) {
                            Text(worry.text)
                            HStack {
                                Text("Added: \(worry.timestamp, formatter: dateFormatter)")
                                Spacer()
                                Text("\(worry.daysAgo) days ago")
                            }
                            .foregroundColor(worry.realized ? .green : .red)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Worry Tracker")
        }
    }
    
    func addWorry() {
        let newWorry = Worry(text: newWorryText, timestamp: Date())
        worries.append(newWorry)
        newWorryText = ""
    }
}

struct Worry: Identifiable {
    let id = UUID()
    let text: String
    let timestamp: Date
    var realized: Bool = false
    
    var daysAgo: Int {
        Calendar.current.dateComponents([.day], from: timestamp, to: Date()).day ?? 0
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
/*
//work but have ipad problem because of navigationview
import SwiftUI

struct ContentView: View {
    @State private var worries: [Worry] = []
    @State private var newWorryText = ""
    @State private var showDeleteConfirmation = false
    @State private var selectedWorry: Worry? = nil
    @State private var showAd: Bool = false
    @State private var showExplain: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                
                HStack{
                    Button(action: {
                        showAd = true
                    }) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)))
                            .padding()
                        Spacer()
                        Text("Worry Bin")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            showExplain = true
                        }) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)))
                                .padding()
                        }
                    }
                }
                Spacer()

                
                TextField("Enter your worry", text: $newWorryText)
                    .padding()
                
                Button(action: addWorry) {
                    Text("Save Worry")
                        .padding()
                        .font(.title3.bold())
                               .foregroundColor(.black) // Text color
                               .background(Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1))) // Background color
                               .cornerRadius(8) // Rounded corners
                }
                .padding()
                
                List {
                    ForEach(worries) { worry in
                        VStack(alignment: .leading) {
                            Text(worry.text)
                            HStack {
                                Text("Added: \(worry.timestamp, formatter: dateFormatter)")
                                Spacer()
                                Text("\(worry.daysAgo) days ago")
                                Button(action: {
                                    toggleRealized(for: worry)
                                }) {
                                    Image(systemName: worry.realized ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(worry.realized ? .green : .primary)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                Button(action: {
                                    selectedWorry = worry
                                    showDeleteConfirmation = true
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .foregroundColor(worry.realized ? .green : .red)
                        }
                    }
                    .onDelete(perform: deleteWorries)
                }
                .listStyle(PlainListStyle())
            }
            .sheet(isPresented: $showAd) {
                ShowAdView(onConfirm: {
                    showAd = false
                })
            }
            .sheet(isPresented: $showExplain) {
                ShowExplainView(onConfirm: {
                    showExplain = false
                })
            }

          
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Worry"),
                    message: Text("Are you sure you want to delete this worry forever?"),
                    primaryButton: .destructive(Text("Yes")) {
                        if let selectedWorry = selectedWorry {
                            deleteWorry(selectedWorry)
                        }
                        selectedWorry = nil
                    },
                    secondaryButton: .cancel(Text("No")) {
                        selectedWorry = nil
                    }
                )
            }
        }
    }
    
    func addWorry() {
        let newWorry = Worry(text: newWorryText, timestamp: Date())
        worries.append(newWorry)
        newWorryText = ""
    }
    
    func toggleRealized(for worry: Worry) {
        if let index = worries.firstIndex(where: { $0.id == worry.id }) {
            worries[index].realized.toggle()
        }
    }
    
    func deleteWorry(_ worry: Worry) {
        if let index = worries.firstIndex(where: { $0.id == worry.id }) {
            worries.remove(at: index)
        }
    }
    
    func deleteWorries(at offsets: IndexSet) {
        worries.remove(atOffsets: offsets)
    }
}

struct Worry: Identifiable {
    let id = UUID()
    let text: String
    let timestamp: Date
    var realized: Bool = false
    
    var daysAgo: Int {
        Calendar.current.dateComponents([.day], from: timestamp, to: Date()).day ?? 0
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()


// MARK: - Ad View
struct ShowAdView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Ads")
                        .font(.largeTitle.bold())
                    Spacer()
                }
                ZStack {
                    Image("threedollar")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(25)
                        .clipped()
                        .onTapGesture {
                            if let url = URL(string: "https://b33.biz/three-dollar/") {
                                UIApplication.shared.open(url)
                            }
                        }
                }
                // App Cards
                VStack {
                    Divider().background(Color.gray)
                    AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                    Divider().background(Color.gray)
                    // Add more AppCardViews here if needed
                    // App Data
                 
                    
                    AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch, for time-sensitive tasks.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, stay motivated.", appURL: "https://apps.apple.com/id/app/temptationtrack/id6471236988")
                    Divider().background(Color.gray)
                
                }
                Spacer()

                // Close Button
                Button("Close") {
                    // Perform confirmation action
                    onConfirm()
                }
                .font(.title)
                .padding()
                .cornerRadius(25.0)
                .padding()
            }
            .padding()
            .cornerRadius(15.0)
            .padding()
        }
    }
}

// MARK: - App Card View
struct AppCardView: View {
    var imageName: String
    var appName: String
    var appDescription: String
    var appURL: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(7)
            
            VStack(alignment: .leading) {
                Text(appName)
                    .font(.title3)
                Text(appDescription)
                    .font(.caption)
            }
            .frame(alignment: .leading)
            
            Spacer()
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Grab")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Explain View
struct ShowExplainView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
               HStack{
                   Text("App Functionality")
                       .font(.title.bold())
                   Spacer()
               }
               
               Text("""
               •Users can enter their worries into a text field and save them.
               •Saved worries are displayed in a list with details such as the date added and how many days ago they were added.
               •Each worry in the list has a "checkmark" button that users can tap to mark the worry as realized (if it has come true).
               •Users can delete worries by tapping the "trash" button next to each worry, with a confirmation dialog to ensure they want to delete it permanently.
               •The app automatically calculates and displays the number of days since each worry was added.
               •We do not collect data, so there's no need to worry
               """)
               .font(.title3)
               .multilineTextAlignment(.leading)
               .padding()
               
               Spacer()
                
                HStack {
                    Text("Worry Bin is developed by Three Dollar.")
                        .font(.title3.bold())
                    Spacer()
                }

               Button("Close") {
                   // Perform confirmation action
                   onConfirm()
               }
               .font(.title)
               .padding()
               .cornerRadius(25.0)
               .padding()
           }
           .padding()
           .cornerRadius(15.0)
           .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

*/



/*
import SwiftUI

struct ContentView: View {
    @State private var worries: [Worry] = []
    @State private var newWorryText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your worry", text: $newWorryText)
                    .padding()
                
                Button(action: addWorry) {
                    Text("Save Worry")
                }
                .padding()
                
                List {
                    ForEach(worries) { worry in
                        VStack(alignment: .leading) {
                            Text(worry.text)
                            HStack {
                                Text("Added: \(worry.timestamp, formatter: dateFormatter)")
                                Spacer()
                                Text("\(worry.daysAgo) days ago")
                            }
                            .foregroundColor(worry.realized ? .green : .red)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Worry Tracker")
        }
    }
    
    func addWorry() {
        let newWorry = Worry(text: newWorryText, timestamp: Date())
        worries.append(newWorry)
        newWorryText = ""
    }
}

struct Worry: Identifiable {
    let id = UUID()
    let text: String
    let timestamp: Date
    var realized: Bool = false
    
    var daysAgo: Int {
        Calendar.current.dateComponents([.day], from: timestamp, to: Date()).day ?? 0
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

*/

/*

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}


/*
//good but wnat to add category
import SwiftUI

struct ContentView: View {
    @State private var worries: [Worry] = []
    @State private var newWorryText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your worry", text: $newWorryText)
                    .padding()
                
                Button(action: addWorry) {
                    Text("Save Worry")
                }
                .padding()
                
                List {
                    ForEach(worries) { worry in
                        VStack(alignment: .leading) {
                            Text(worry.text)
                            HStack {
                                Text("Added: \(worry.timestamp, formatter: dateFormatter)")
                                Spacer()
                                Text("\(worry.daysAgo) days ago")
                                Button(action: {
                                    toggleRealized(for: worry)
                                }) {
                                    Image(systemName: worry.realized ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(worry.realized ? .green : .primary)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                Button(action: {
                                    deleteWorry(worry)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .foregroundColor(worry.realized ? .green : .red)
                        }
                    }
                    .onDelete(perform: deleteWorries)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Worry Bin")
            .navigationBarItems(trailing: EditButton())
        }
    }
    
    func addWorry() {
        let newWorry = Worry(text: newWorryText, timestamp: Date())
        worries.append(newWorry)
        newWorryText = ""
    }
    
    func toggleRealized(for worry: Worry) {
        if let index = worries.firstIndex(where: { $0.id == worry.id }) {
            worries[index].realized.toggle()
        }
    }
    
    func deleteWorry(_ worry: Worry) {
        if let index = worries.firstIndex(where: { $0.id == worry.id }) {
            worries.remove(at: index)
        }
    }
    
    func deleteWorries(at offsets: IndexSet) {
        worries.remove(atOffsets: offsets)
    }
}

struct Worry: Identifiable {
    let id = UUID()
    let text: String
    let timestamp: Date
    var realized: Bool = false
    
    var daysAgo: Int {
        Calendar.current.dateComponents([.day], from: timestamp, to: Date()).day ?? 0
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

*/

/*
import SwiftUI

struct ContentView: View {
    @State private var worries: [Worry] = []
    @State private var newWorryText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your worry", text: $newWorryText)
                    .padding()
                
                Button(action: addWorry) {
                    Text("Save Worry")
                }
                .padding()
                
                List {
                    ForEach(worries) { worry in
                        VStack(alignment: .leading) {
                            Text(worry.text)
                            HStack {
                                Text("Added: \(worry.timestamp, formatter: dateFormatter)")
                                Spacer()
                                Text("\(worry.daysAgo) days ago")
                            }
                            .foregroundColor(worry.realized ? .green : .red)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Worry Tracker")
        }
    }
    
    func addWorry() {
        let newWorry = Worry(text: newWorryText, timestamp: Date())
        worries.append(newWorry)
        newWorryText = ""
    }
}

struct Worry: Identifiable {
    let id = UUID()
    let text: String
    let timestamp: Date
    var realized: Bool = false
    
    var daysAgo: Int {
        Calendar.current.dateComponents([.day], from: timestamp, to: Date()).day ?? 0
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

*/
/*

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
 
 */*/*/
