//
//  AddPairsView.swift
//  Pairs
//
//  Created by Jahn Michel on 28.09.24.
//

import SwiftUI
import SwiftData

struct AddPairsView: View {
    
    @Bindable var set: PairSet
    @State private var front: String = ""
    @State private var back: String = ""
    @State private var text: String? = nil
    @State private var showImportView: Bool = false
    @State private var showFileImporter: Bool = false
    @State private var showImportInfo: Bool = false
    
    var body: some View {
        Form {
            Section("Single Card") {
                TextField("Front", text: $front)
                TextField("Back", text: $back)
                HStack {
                    Spacer()
                    Button("Add") {
                        _ = set.AddPair(front: front, back: back, rebuild: true)
                        front = ""
                        back = ""
                    }
                    Spacer()
                }
            }
            Section {
                HStack {
                    Spacer()
                    Button("Paste") {
                        if let clipboard = UIPasteboard.general.string {
                            text = clipboard
                            showImportView = true
                        }
                    }
                    Spacer()
                }
            } header: {
                HStack {
                    Text("From Clipboard")
                    Button {
                        showImportInfo = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                }
            }
            Section {
                HStack {
                    Spacer()
                    Button("Browse") {
                        showFileImporter = true
                    }
                    Spacer()
                }
            } header: {
                HStack {
                    Text("From Text File")
                    Button {
                        showImportInfo = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                }
            }
        }
        .navigationTitle("Add cards")
        .popover(isPresented: $showImportView) {
            ImportPairsView(set: .constant(set), url: .constant(nil), text: $text)
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.plainText]) { result in
            switch result {
            case .success(let url):
                do {
                    let accessGranted = url.startAccessingSecurityScopedResource()
                    if accessGranted {
                        text = try String(contentsOf: url, encoding: .utf8)
                        showImportView = true
                    } else {
                        print("access denied")
                    }
                    url.stopAccessingSecurityScopedResource()
                } catch {
                    print("could not get text from url")
                }
            case .failure(let error):
                print(error)
            }
        }
        .sheet(isPresented: $showImportInfo) {
            InfoSheet()
        }
    }
}

struct InfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let text = "To import cards from clipboard or file, the source has to be plain text (.txt, utf-8). Two consecutive lines will be interpreted as one card. First line will be the front face, second will be the back. Empty lines will be ignored as well as the last line in case of an odd number of lines. You can also share compatible text files from other apps if they support sharing."
    
    var body: some View {
        VStack {
            ScrollView {
                Text(text)
                    .padding()
            }
            Spacer()
            Button("OK", role: .cancel) {
                dismiss()
            }
        }
        .presentationDetents([.fraction(1.0 / 3.0), .medium])
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
        
        return AddPairsView(set: germanVocab)
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}
