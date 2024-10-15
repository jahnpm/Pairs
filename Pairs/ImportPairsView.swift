//
//  ImportPairsView.swift
//  Pairs
//
//  Created by Jahn Michel on 26.09.24.
//

import SwiftUI
import SwiftData

struct ImportPairsView: View {
    @Environment(\.dismiss) var dismiss
    @Query var PairSets: [PairSet]
    @Binding var set : PairSet?
    @Binding var url : URL?
    @Binding var text : String?
    @State private var preview: [(String, String)] = []
    @State private var isImportFinished: Bool = false
    @State private var importCount: Int = 0
    
    var body: some View {
        NavigationView {
            Form {
                if set == nil {
                    Section("Select Set") {
                        List(PairSets, id: \.self) {set in
                            HStack {
                                Text(set.name)
                                Spacer()
                                Button("Import") {
                                    importCount = set.AddFromTuples(array: preview)
                                    isImportFinished = true
                                }
                            }
                        }
                    }
                }
                if (!preview.isEmpty) {
                    Section("Preview") {
                        List(preview, id: \.0) {pair in
                            VStack(alignment: .leading) {
                                Text(pair.0)
                                Text(pair.1)
                                    .font(.footnote)
                            }
                        }
                    }
                }
            }
            .alert("Finished", isPresented: $isImportFinished) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("\(importCount) cards added")
            }
            .navigationTitle("Import Cards")
            .toolbar {
                if set != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Import") {
                            importCount = set!.AddFromTuples(array: preview)
                            isImportFinished = true
                        }
                    }
                }
            }
            .onAppear() {
                if url == nil && text == nil {
                    return
                }
                if url == nil {
                    preview = PairSet.getPairsFrom(text: text!)
                } else {
                    do {
                        preview = PairSet.getPairsFrom(text: try String.init(contentsOf: url!, encoding: .utf8))
                    } catch {
                        print("ERROR: Could not create string from url")
                    }
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
        let germanVocab2 = PairSet(name: "German Vocabulary 2")
        _ = germanVocab2.AddFromTuples(
            array:[("Haus","house"),("Schiff","ship"),("Tier","animal")]
        )
        let germanVocab3 = PairSet(name: "German Vocabulary 3")
        _ = germanVocab3.AddFromTuples(
            array:[("Haus","house"),("Schiff","ship"),("Tier","animal")]
        )
        
        container.mainContext.insert(germanVocab)
        container.mainContext.insert(germanVocab2)
        container.mainContext.insert(germanVocab3)
        
        return ImportPairsView.init(set: .constant(nil), url: .constant(nil), text: .constant(nil))
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}
