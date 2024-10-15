//
//  EditPairsView.swift
//  Pairs
//
//  Created by Jahn Michel on 22.09.24.
//

import SwiftUI
import SwiftData

struct EditPairsView: View {
    @Environment(\.editMode) private var editMode
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var set : PairSet
    
    @State var searchText: String = ""
    @State var showingFavorites: Bool = false
    @State private var selectedPairs: Set<String> = Set<String>()
    
    @State var confirmDeletion: Bool = false
    @State var confirmNewSet: Bool = false
    
    var body: some View {
        VStack {
            List(selection: $selectedPairs) {
                ForEach(FilterPairs(), id: \.self) { key in
                    NavigationLink {
                        EditPairView(set: set, key: key)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(set.pairs[key]?.front ?? "")
                                Text(set.pairs[key]?.back ?? "")
                                    .font(.footnote)
                            }
                            Spacer()
                            Image(systemName: "star.fill")
                                .foregroundStyle(set.pairs[key]!.favorite ? Color(uiColor: .systemYellow) : Color(uiColor: .systemGray5))
                        }
                    }
                }
            }
            .searchable(text: $searchText)
        }
        .confirmationDialog("", isPresented: $confirmDeletion, presenting: selectedPairs) { data in
            let selected = data as Set<String>
            Button("Delete \(selected.count) cards", role: .destructive) {
                DeleteSelection()
            }
        }
        .confirmationDialog("", isPresented: $confirmNewSet, presenting: selectedPairs) { data in
            let selected = data as Set<String>
            Button("Create new set from \(selected.count) selected cards") {
                CreateSetFromSelection()
            }
        }
        .navigationTitle("Manage cards")
        .toolbar() {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
            if editMode?.wrappedValue.isEditing == true {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button() {
                        if !selectedPairs.isEmpty {
                            confirmNewSet = true
                        }
                    } label: {
                        Text("Make set")
                    }
                    Spacer()
                    Button() {
                        ToggleFavoriteSelection()
                    } label: {
                        Image(systemName: "star.fill")
                    }
                    Spacer()
                    Button {
                        if !selectedPairs.isEmpty {
                            confirmDeletion = true
                        }
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(Color(uiColor: .systemRed))
                    }
                }
            } else {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button() {
                        showingFavorites.toggle()
                    } label: {
                        Text(showingFavorites ? "Show all" : "Show favorites")
                    }
                    Spacer()
                    NavigationLink {
                        AddPairsView(set: set)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onAppear() {
            selectedPairs.removeAll()
        }
    }
    
    func ToggleFavoriteSelection() {
        for key in selectedPairs {
            set.toggleFavorite(key: key)
        }
        withAnimation {
            editMode?.wrappedValue = .inactive
        }
    }
    
    func CreateSetFromSelection() {
        let newSet = PairSet(name: "New Set")
        let tuples = selectedPairs.map{ key in
            return (key, set.pairs[key]!.back)
        }
        _ = newSet.AddFromTuples(array: tuples)
        modelContext.insert(newSet)
        withAnimation {
            editMode?.wrappedValue = .inactive
        }
    }
    
    func DeleteSelection() {
        for key in selectedPairs {
            set.RemovePair(front: key)
        }
        withAnimation {
            editMode?.wrappedValue = .inactive
        }
    }
    
    func DeletePairs(_ indexSet: IndexSet) {
        for index in indexSet {
            let key = FilterPairs()[index]
            set.RemovePair(front: key)
        }
    }
    
    func FilterPairs() -> [String] {
        if searchText != "" {
            let cachedKeys = showingFavorites ? set.cachedFavoritesKeys : set.cachedSortedKeys
            return cachedKeys.filter() { key in
                key.contains(searchText) || set.pairs[key]!.back.contains(searchText)
            }
        } else {
            return showingFavorites ? set.cachedFavoritesKeys : set.cachedSortedKeys
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
        
        return NavigationStack { EditPairsView(set: germanVocab) }
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}
