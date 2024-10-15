//
//  EditPairView.swift
//  Pairs
//
//  Created by Jahn Michel on 29.09.24.
//

import SwiftUI
import SwiftData


struct EditPairView: View {
    
    @Bindable var set : PairSet
    @State var key : String
    @State var newFront : String
    @State var newBack : String
    @State var isFavorite : Bool
    @State var isIllegalKey : Bool = false
    
    init(set: PairSet, key: String) {
        self.set = set
        self._key = State(initialValue: key)
        self._newFront = State(initialValue: key)
        self._newBack = State(initialValue: set.pairs[key]!.back)
        self._isFavorite = State(initialValue: set.pairs[key]!.favorite)
    }
    
    var body: some View {
        VStack {
            if isIllegalKey {
                Text("Card front already exists")
                    .foregroundStyle(Color(uiColor: .systemRed))
                    .padding([.top, .leading, .trailing])
            }
            Form {
                TextField("front", text: $newFront)
                TextField("back", text: $newBack)
                Section {
                    Toggle("Favorite", isOn: $isFavorite)
                }
            }
        }
        .navigationTitle("Edit \(key)")
        .onChange(of: newFront) { _, newKey in
            if newKey != key && set.pairs[newKey] != nil {
                isIllegalKey = true
            } else {
                isIllegalKey = false
            }
        }
        .onDisappear {
            if !isIllegalKey {
                set.RemovePair(front: key)
                _ = set.AddPair(front: newFront, back: newBack, rebuild: true)
                if isFavorite {
                    set.toggleFavorite(key: newFront)
                }
            }
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
        
        return EditPairView(set: germanVocab, key: "Haus")
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}
