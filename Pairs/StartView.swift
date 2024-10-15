//
//  StartView.swift
//  Pairs
//
//  Created by Jahn Michel on 19.09.24.
//

import SwiftUI
import SwiftData

struct StartView: View {
    
    @Environment(\.modelContext) var modelContext
    
    @Query var PairSets: [PairSet]
    
    @State var showingPopover = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(PairSets) {pairSet in
                    NavigationLink() {
                        PracticeView(set: pairSet)
                    } label: {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(pairSet.name)
                                    .font(.headline)
                                Spacer()
                                if pairSet.favoritesOnly {
                                    Image(systemName: "star")
                                }
                                if pairSet.reversedSides {
                                    Image(systemName: "arrow.2.squarepath")
                                }
                            }
                            HStack {
                                Text(String(pairSet.pairs.count) + " card(s)")
                            }
                        }
                    }
                }
                .onDelete(perform: DeleteSets)
            }
            .listRowSpacing(10)
            .navigationTitle("Sets")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button() {
                        modelContext.insert(PairSet(name: "New Set"))
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    func DeleteSets(_ indexSet: IndexSet) {
        for index in indexSet {
            let set = PairSets[index]
            modelContext.delete(set)
        }
    }
}

#Preview {
    MainActor.assumeIsolated {
        StartView()
            .modelContainer(for: PairSet.self)
    }
}
