import Foundation
import ReactiveSwift
import Result

class VMCardShowingScreen{
    private let database: Storage
    public let currentWord : Property<Word?>

    init(database: Storage) {
        self.database = database
        currentWord = database.remainingToday.first
    }

    @objc public func wordWasGuessed() {
        database.registerFeedback(true, for: currentWord.value!.text, at: .now)
    }

    @objc public func wordWasNotGuessed(){
        database.registerFeedback(true, for: currentWord.value!.text, at: .now)
    }
}
