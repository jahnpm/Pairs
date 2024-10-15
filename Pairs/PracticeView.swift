//
//  PracticeView.swift
//  Pairs
//
//  Created by Jahn Michel on 19.09.24.
//

import SwiftUI
import SwiftData

struct PracticeView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Bindable var set: PairSet
    
    @State var displayedPair: Pair? = nil
    @State var yOffset: CGFloat = 0
    @State var showCard: Bool = true
    @State var movingUp: Bool = true
    @State var touching: Bool = false
    
    @GestureState var tapping = false
    
    init(set: PairSet) {
        self.set = set
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            if displayedPair != nil {
                VStack {
                    HStack {
                        Image(systemName: "arrow.up")
                            .foregroundStyle(Color(uiColor: .systemGreen))
                        Text("right")
                            .font(.headline)
                            .foregroundStyle(Color(uiColor: .systemGreen))
                    }
                    Spacer()
                    HStack {
                        Image(systemName: "arrow.down")
                            .foregroundStyle(Color(uiColor: .systemRed))
                        Text("wrong")
                            .font(.headline)
                            .foregroundStyle(Color(uiColor: .systemRed))
                    }
                }
                VStack {
                    if showCard {
                        VStack {
                            ZStack {
                                Text(set.reversedSides != touching ? displayedPair!.back : displayedPair!.front)
                                Button() {
                                    set.toggleFavorite(key: displayedPair!.front)
                                    if set.favoritesOnly {
                                        getNextPair()
                                    } else {
                                        displayedPair = set.pairs[displayedPair!.front]
                                    }
                                } label: {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(displayedPair!.favorite ? Color(uiColor: .systemYellow) : Color(uiColor: .systemGray4))
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            }
                            .font(.largeTitle)
                            .frame(width: 275, height: 200, alignment: .center)
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .offset(CGSize(width: 0, height: yOffset))
                        }
                        .transition(movingUp ? .move(edge: .top) : .move(edge: .bottom))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .contentShape(Rectangle())
                        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
                            .updating($tapping, body: { _, _, _ in
                                if !(touching) { touching = true }
                            })
                            .onChanged() { value in
                                yOffset = value.translation.height
                            }
                            .onEnded(dragGestureEnded))
                    }
                }
            } else {
                Text("No Cards").font(.largeTitle)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    EditSetView(set: set)
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .onAppear() {
            getNextPair()
        }
    }
    
    func dragGestureEnded(value: DragGesture.Value) {
        if value.translation.height < -40 {
            movingUp = true
            withAnimation { showCard = false } completion: {
                showCard = true
            }
            set.decrementProbability(front: displayedPair!.front)
            getNextPair()
        } else {
            if value.translation.height > 40 {
                movingUp = false
                withAnimation { showCard = false } completion: {
                    showCard = true
                }
                set.incrementProbability(front: displayedPair!.front)
                set.ForcePair(key: displayedPair!.front)
                getNextPair()
            }
        }
        yOffset = 0
        touching = false
    }
    
    func getNextPair() {
        let next = set.getNext()
        displayedPair = (next == nil) ? nil : set.pairs[next!]
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
        
        return NavigationStack { PracticeView(set: germanVocab) }
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}
