//
//  PairSet.swift
//  Pairs
//
//  Created by Jahn Michel on 17.09.24.
//
import SwiftData

@Model
class PairSet {
    var name: String
    private(set) var pairs: Dictionary<String,Pair> = [:]
    private(set) var inflatedKeys: [String] = []
    private(set) var favInflatedKeys: [String] = []
    private(set) var forcedKeys: [KeyCounter] = []
    private(set) var cachedSortedKeys: [String] = []
    private(set) var cachedFavoritesKeys: [String] = []
    var reversedSides = false
    var favoritesOnly = false
    
    init(name: String = "New Set") {
        self.name = name
    }
    
    func sortFavoritesCache() {
        cachedFavoritesKeys = cachedFavoritesKeys.sorted() {a, b in
            return a.lowercased() < b.lowercased()
        }
    }
    
    func RebuildSortedKeysCache() {
        cachedSortedKeys = pairs.keys.sorted() {a, b in
            return a.lowercased() < b.lowercased()
        }
    }
    
    static func getPairsFrom(text: String) -> [(String, String)] {
        var foundPairs: [(String, String)] = []
        
        var separatedLines = text.components(separatedBy: .newlines)
        separatedLines.removeAll() { line in
            line.isEmpty || line.allSatisfy() { character in
                character.isWhitespace
            }
        }
        
        if separatedLines.count >= 2 {
            for i in stride(from: 0, to: separatedLines.count, by: 2) {
                if i+1 == separatedLines.count {
                    break
                }
                separatedLines[i].removeAll(where: { $0.isNewline })
                separatedLines[i+1].removeAll(where: { $0.isNewline })
                foundPairs.append((separatedLines[i], separatedLines[i+1]))
            }
        }
        
        return foundPairs
    }
    
    func AddFromTuples(array: [(String, String)]) -> Int {
        pairs.reserveCapacity(pairs.count + array.count)
        var count = 0
        for pair in array {
            let success = AddPair(front: pair.0, back: pair.1, rebuild: false)
            if success {
                count += 1
            }
        }
        RebuildSortedKeysCache()
        return count
    }
    
    func AddPair(front: String, back: String, rebuild: Bool) -> Bool {
        if pairs[front] != nil {
            return false
        }
        pairs[front] = Pair(front: front, back: back)
        inflatedKeys.append(front)
        if rebuild {
            RebuildSortedKeysCache()
        }
        return true
    }
    
    func ChangeBackOf(key: String, back: String) {
        if pairs[key] == nil {
            return
        }
        pairs[key]!.back = back
    }
    
    func RemovePair(front: String) {
        if pairs[front] != nil && pairs[front]!.favorite {
            cachedFavoritesKeys.remove(at: cachedFavoritesKeys.firstIndex(of: front)!)
            favInflatedKeys.removeAll() { $0 == front }
        }
        pairs[front] = nil
        inflatedKeys.removeAll() { $0 == front }
        
        RebuildSortedKeysCache()
    }
    
    func incrementProbability(front: String) {
        if pairs[front] == nil {
            return
        }
        if pairs[front]!.probability >= inflatedKeys.count / 10 {
            return
        }
        pairs[front]!.probability += 1
        inflatedKeys.append(front)
        if pairs[front]!.favorite {
            favInflatedKeys.append(front)
        }
    }
    
    func decrementProbability(front: String) {
        if pairs[front] == nil {
            return
        }
        if pairs[front]!.probability > 1 {
            pairs[front]!.probability -= 1
        }
        let i = inflatedKeys.firstIndex(of: front)
        if i != nil {
            inflatedKeys.remove(at: i!)
        }
        if pairs[front]!.favorite {
            let j = favInflatedKeys.firstIndex(of: front)
            if j != nil {
                favInflatedKeys.remove(at: j!)
            }
        }
    }
    
    func toggleFavorite(key: String) {
        if pairs[key] == nil {
            return
        }
        
        pairs[key]!.favorite.toggle()
        
        if pairs[key]!.favorite {
            favInflatedKeys.append(key)
            cachedFavoritesKeys.append(key)
            sortFavoritesCache()
        } else {
            favInflatedKeys.removeAll() { $0 == key }
            cachedFavoritesKeys.remove(at: cachedFavoritesKeys.firstIndex(of: key)!)
        }
    }
    
    func ForcePair(key: String) {
        if pairs[key] == nil {
            return
        }
        forcedKeys.append(KeyCounter(key: key))
    }
    
    func getNext() -> String? {
        if forcedKeys.count > 0 {
            for i in 0..<forcedKeys.count {
                forcedKeys[i].counter -= 1
            }
            if forcedKeys[0].counter == 0 {
                let forcedKey = forcedKeys[0].key
                forcedKeys.removeFirst()
                return forcedKey
            }
        }
        
        let randomKey: String?
        if favoritesOnly {
            if favInflatedKeys.isEmpty {
                favInflatedKeys = Array(pairs.keys).filter() { key in
                    pairs[key]!.favorite
                }
            }
            randomKey = favInflatedKeys.randomElement()
        } else {
            if inflatedKeys.isEmpty {
                inflatedKeys = Array(pairs.keys)
            }
            randomKey = inflatedKeys.randomElement()
        }
        return randomKey
    }
}

struct Pair: Encodable, Decodable {
    var front: String = ""
    var back: String = ""
    var probability: Int = 1
    var favorite: Bool = false
}

struct KeyCounter: Encodable, Decodable {
    var key: String = ""
    var counter: Int = 10
}
