//
//  EditSetView.swift
//  Pairs
//
//  Created by Jahn Michel on 17.09.24.
//

import SwiftUI
import SwiftData

struct EditSetView: View {
    @Bindable var set : PairSet
    @State var multilineText : String = ""
    @State var searchString : String = ""
    @State var alertShown: Bool = false
    @State var pairsAdded: Int = 0
    @State var showImportView: Bool = false
    @State var url: URL? = nil
    
    var body: some View {
        Form {
            Section("Name") {
                TextField("Name", text: $set.name)
            }
            Section("Manage Cards") {
                NavigationLink {
                    EditPairsView(set: set)
                } label: {
                    Text("Cards")
                    Text("(" + String(set.pairs.count) + ")")
                }
            }
            Section("Settings") {
                Toggle(isOn: $set.reversedSides) { Text("Reversed Sides") }
                Toggle(isOn: $set.favoritesOnly) { Text("Favorites Only") }
            }
        }
        .navigationTitle("Edit set")
        .navigationBarTitleDisplayMode(.inline)
        .onOpenURL() { url in
            self.url = url
            showImportView = true
        }
        .popover(isPresented: $showImportView) {
            ImportPairsView(set: .constant(nil), url: $url, text: .constant(nil))
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PairSet.self, configurations: config)
        
        let germanVocab = PairSet(name: "German Vocabulary")
        _ = germanVocab.AddFromTuples(
            array:[("Haus","house"),("Schiff","ship"),("Tier","animal")]
        )
        
        return EditSetView(set: germanVocab)
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}
