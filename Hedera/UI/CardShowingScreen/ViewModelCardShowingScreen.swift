import Foundation
import ReactiveSwift
import Result

class VMCardShowingScreen{
    private let database: Storage
    let currentWord : Property<Word?>

    init(database: Storage) {
        self.database = database
        currentWord = database.remainingToday.first
    }

    @objc func wordWasGuessed() {
        database.registerFeedback(true, for: currentWord.value!.text, at: .now)
    }

    @objc func wordWasNotGuessed(){
        database.registerFeedback(true, for: currentWord.value!.text, at: .now)
    }
}
