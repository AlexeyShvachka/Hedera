import XCTest
import Quick
import ReactiveSwift
import Nimble
import Result
@testable import Hedera



extension Word {
    init(_ word: String){
        self.text = word
        self.added = .now
        self.willShow = .tommorow
        self.bestTranslation = ""
        self.folder = .fresh
        self.translationsProvider = {[]}
    }
}

class PersistantStorageSpec: QuickSpec {
    override func spec() {
        describe("Persistnant storage"){
            var subject: PersistantStorage!
            let word = Word("word")
            let translations = ["tr1", "tr2"]
            beforeEach {
                let database = CoreDataWrapper(setUpInMemoryManagedObjectContext(),
                                               ImidiateSpaceManager())
                let countProvider = InMemoryCountProvider()
                subject = PersistantStorage(with: database, countStorage: countProvider)
                subject.addWord("word", with: translations)
            }
            describe("adding new element"){
                it("should appear in allWords"){
                    expect(subject.allWords.value).to(contain(word))
                }
                it("should appear in due words"){
                    expect(subject.remainingToday.value).to(contain(word))
                }
            }
            describe("providing feedback"){
                beforeEach {
                    subject.registerFeedback(true, for: "word")
                }
                it("should notify in allWords signal"){
                    let allWords = subject.allWords.value
                    let guessedWord: Word = allWords.first{$0 == word}!
                    expect(guessedWord.folder).to(equal(Phase.seen))
                }
                it("should remove word from remainings"){
                        expect(subject.remainingToday.value).toNot(contain(word))
                }
            }
        }
    }
}



