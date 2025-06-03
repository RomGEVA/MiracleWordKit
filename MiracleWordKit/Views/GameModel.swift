import Foundation
import SwiftUI

class GameModel: ObservableObject {
    @Published var currentWord: String = ""
    @Published var guessedLetters: Set<Character> = []
    @Published var incorrectAttempts: Int = 0
    @Published var gameState: GameState = .playing
    @Published var isSoundEnabled: Bool = true
    @Published var difficulty: Difficulty = .medium
    @Published var currentLevel: Int = 0
    @Published var isLevelCompleted: Bool = false
    @Published var timeRemaining: Int = 0
    @Published var timerActive: Bool = false
    @Published var hintUsed: Bool = false
    @Published var hintsLeft: Int = 3

    @AppStorage("maxUnlockedLevel") private var maxUnlockedLevel: Int = 0
    @AppStorage("completedLevels") private var completedLevelsString: String = ""
    @AppStorage("hintsLeft") private var storedHintsLeft: Int = 3

    let maxAttempts = 5
    var timer: Timer?
    let hintPenalty: Int = 10 // seconds
    let maxHints: Int = 3

    struct Level: Identifiable, Codable {
        let id: Int
        let word: String
        let hint: String
    }

    let levels: [Level] = [
        Level(id: 0, word: "CAT", hint: "Who says 'meow'?"),
        Level(id: 1, word: "DOG", hint: "Man's best friend."),
        Level(id: 2, word: "BIRD", hint: "It flies and sings in the trees."),
        Level(id: 3, word: "TREE", hint: "It grows in the forest and has leaves and branches."),
        Level(id: 4, word: "BOOK", hint: "It has many pages and stories inside."),
        Level(id: 5, word: "APPLE", hint: "A red or green fruit that falls from a tree."),
        Level(id: 6, word: "HOUSE", hint: "People live in it."),
        Level(id: 7, word: "GARDEN", hint: "A place where flowers and vegetables grow."),
        Level(id: 8, word: "PENCIL", hint: "You write or draw with it, and you can erase it."),
        Level(id: 9, word: "TIGER", hint: "A big striped cat from the jungle."),
        Level(id: 10, word: "MONKEY", hint: "Loves bananas and climbs trees."),
        Level(id: 11, word: "ELEPHANT", hint: "The largest land animal with a trunk."),
        Level(id: 12, word: "COMPUTER", hint: "An electronic device for work and play."),
        Level(id: 13, word: "MOUNTAIN", hint: "A very high part of the earth, hard to climb."),
        Level(id: 14, word: "RAINBOW", hint: "Appears in the sky after rain and has many colors."),
        Level(id: 15, word: "BANANA", hint: "A long yellow fruit, monkeys love it."),
        Level(id: 16, word: "CAR", hint: "You drive it on the road."),
        Level(id: 17, word: "FISH", hint: "Lives in water and swims."),
        Level(id: 18, word: "SUN", hint: "The star at the center of our solar system."),
        Level(id: 19, word: "MOON", hint: "It shines at night and orbits the Earth."),
        Level(id: 20, word: "CHAIR", hint: "You sit on it."),
        Level(id: 21, word: "TABLE", hint: "You eat or work at it."),
        Level(id: 22, word: "PHONE", hint: "You use it to call and text people."),
        Level(id: 23, word: "WATCH", hint: "You wear it on your wrist to tell time."),
        Level(id: 24, word: "SHOE", hint: "You wear it on your foot."),
        Level(id: 25, word: "BREAD", hint: "You eat it, often with butter or jam."),
        Level(id: 26, word: "PLANE", hint: "It flies in the sky and carries people."),
        Level(id: 27, word: "DOOR", hint: "You open and close it to enter a room."),
        Level(id: 28, word: "CLOUD", hint: "White and fluffy, floats in the sky."),
        Level(id: 29, word: "STAR", hint: "A bright point of light in the night sky."),
        Level(id: 30, word: "RIVER", hint: "A long stream of water that flows to the sea."),
        Level(id: 31, word: "HORSE", hint: "A strong animal you can ride."),
        Level(id: 32, word: "BREAD", hint: "A basic food, often used for sandwiches."),
        Level(id: 33, word: "CANDLE", hint: "It gives light when you light it."),
        Level(id: 34, word: "PILLOW", hint: "You rest your head on it when you sleep."),
        Level(id: 35, word: "SNAKE", hint: "A long, legless reptile."),
        Level(id: 36, word: "FROG", hint: "A green animal that jumps and croaks."),
        Level(id: 37, word: "SPOON", hint: "You use it to eat soup."),
        Level(id: 38, word: "TRAIN", hint: "A long vehicle that runs on tracks."),
        Level(id: 39, word: "CROWN", hint: "A king or queen wears it on their head."),
        Level(id: 40, word: "BEE", hint: "A small insect that makes honey."),
        Level(id: 41, word: "LION", hint: "The king of the jungle."),
        Level(id: 42, word: "SHEEP", hint: "A farm animal with wool."),
        Level(id: 43, word: "DUCK", hint: "A bird that swims and quacks."),
        Level(id: 44, word: "LEMON", hint: "A sour yellow fruit."),
        Level(id: 45, word: "CHAIR", hint: "You sit on it."),
        Level(id: 46, word: "BREAD", hint: "A basic food, often used for sandwiches."),
        Level(id: 47, word: "CUP", hint: "You drink tea or coffee from it."),
        Level(id: 48, word: "PIZZA", hint: "A popular Italian dish with cheese and tomato."),
        Level(id: 49, word: "ROBOT", hint: "A machine that can do tasks automatically.")
    ]

    enum Difficulty: String, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        var maxWordLength: Int {
            switch self {
            case .easy: return 4
            case .medium: return 6
            case .hard: return 8
            }
        }
        var timeLimit: Int {
            switch self {
            case .easy: return 60
            case .medium: return 40
            case .hard: return 25
            }
        }
    }

    enum GameState {
        case playing
        case won
        case lost
        case timeout
    }

    var completedLevels: Set<Int> {
        get {
            Set(completedLevelsString.split(separator: ",").compactMap { Int($0) })
        }
        set {
            completedLevelsString = newValue.map { String($0) }.joined(separator: ",")
        }
    }

    func startLevel(_ level: Int) {
        guard level < levels.count else { return }
        currentLevel = level
        currentWord = levels[level].word
        guessedLetters.removeAll()
        incorrectAttempts = 0
        gameState = .playing
        isLevelCompleted = completedLevels.contains(level)
        hintUsed = false
        hintsLeft = storedHintsLeft
        startTimer()
    }

    func startNextLevel() {
        let nextLevel = currentLevel + 1
        if nextLevel < levels.count {
            startLevel(nextLevel)
        }
    }

    func guessLetter(_ letter: Character) {
        guard gameState == .playing else { return }
        let upperLetter = letter.uppercased().first!
        guessedLetters.insert(upperLetter)
        if !currentWord.contains(upperLetter) {
            incorrectAttempts += 1
            if incorrectAttempts >= maxAttempts {
                stopTimer()
                gameState = .lost
            }
        } else if isWordComplete() {
            stopTimer()
            gameState = .won
            completeCurrentLevel()
        }
    }

    func isWordComplete() -> Bool {
        currentWord.allSatisfy { guessedLetters.contains($0) }
    }

    func getMaskedWord() -> String {
        currentWord.map { guessedLetters.contains($0) ? String($0) : "_" }
            .joined(separator: " ")
    }

    func getRemainingLetters() -> [Character] {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return alphabet.filter { !guessedLetters.contains($0) }
    }

    func setDifficulty(_ newDifficulty: Difficulty) {
        difficulty = newDifficulty
    }

    func completeCurrentLevel() {
        completedLevels.insert(currentLevel)
        isLevelCompleted = true
        if currentLevel >= maxUnlockedLevel {
            maxUnlockedLevel = currentLevel + 1
        }
    }

    func isLevelUnlocked(_ level: Int) -> Bool {
        level <= maxUnlockedLevel
    }

    func isLevelPassed(_ level: Int) -> Bool {
        completedLevels.contains(level)
    }

    func resetProgress() {
        maxUnlockedLevel = 0
        completedLevels = []
    }

    // Timer logic
    func startTimer() {
        stopTimer()
        timeRemaining = difficulty.timeLimit
        timerActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tickTimer()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timerActive = false
    }

    func tickTimer() {
        guard timerActive, gameState == .playing else { return }
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            timerActive = false
            stopTimer()
            gameState = .timeout
        }
    }

    func useHint() {
        guard !hintUsed, hintsLeft > 0, gameState == .playing else { return }
        hintUsed = true
        hintsLeft -= 1
        storedHintsLeft = hintsLeft
        timeRemaining = max(0, timeRemaining - hintPenalty)
        if timeRemaining == 0 {
            stopTimer()
            gameState = .timeout
        }
    }

    func resetHints() {
        hintsLeft = maxHints
        storedHintsLeft = maxHints
    }

    var lastUnlockedLevel: Int {
        maxUnlockedLevel
    }
} 