import Foundation
import XCTest
import Quick
import ReactiveSwift
import Nimble
import Result
@testable import Hedera

class TranslationCheckerSpec: QuickSpec{
    override func spec() {
        describe("translation checker"){
            var subject: TranslationChecker!
            var storage: Storage!
            beforeEach {
                storage = setUpInMemoryStorage()
                subject = TranslationChecker(UnreliableTranslator(),
                                             storage,
                                             0.1.seconds,
                                             setUpInMemoryManagedObjectContext())
            }
            context("when translation not avaliable on first try"){
                beforeEach {
                    subject.add("word")
                }
                it("should storage about new"){
                    expect(subject.words.value).to(contain("word"))
                }
                it("should eventualy translate"){
                    expect(storage.allWords.value).toEventually(contain(Word("word")))
                    expect(subject.words.value).toEventuallyNot(contain("word"))
                }
            }
        }
    }
}
