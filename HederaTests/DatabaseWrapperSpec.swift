import Foundation
import XCTest
import Quick
import ReactiveSwift
import Nimble
import Result
@testable import Hedera


class DatabaseWrapperSpec: QuickSpec {
    override func spec() {
        describe("CoreDataWrapper"){
            var subject : CoreDataWrapper!
            beforeEach {
                subject = CoreDataWrapper(setUpInMemoryManagedObjectContext(),
                                          ImidiateSpaceManager())
            }
            context("after adding element"){
                beforeEach {
                    subject.addWord("Kočka", with: ["t1", "t2"])
                }
                it("should store this word"){
                    expect(subject.getWords()).to(contain(Word("Kočka")))
                }
                it("should be able to recover translations"){
                    expect(subject.getTranslations(of: "kocka")).to(contain(["t1","t2"]))
                }
                it("should be avaliable after due date"){
                    //Imidiate scheduler set new words to be due now
                    expect(subject.getRemaining()).to(contain(Word("Kočka")))
                }
                it("should be able to find it diacritics and case insensitive"){
                    expect(subject.getWordForSearch("kocka")!).to(equal(
                        Word("Kočka")))
                    expect(subject.getWordForSearch("kocka")!.allTranslations).to(contain(["t1","t2"]))
                }
            }
            context("after feedback is provided"){
                beforeEach {
                    subject.addWord("word2", with: ["t1", "t2"])
                    subject.registerFeedback(true, for: "word2", at: .now)
                }
                it("should remove this word from remaining"){
                    expect(subject.getRemaining()).toNot(contain(Word("word2")))
                }
                it("should still have this word stored"){
                    expect(subject.getWords()).to(contain(Word("word2")))
                }
                it("should update words phase"){
                    expect(subject.getWords().first{$0 == Word("word2")}!.folder).to(equal(Phase.seen))
                }
            }
        }
    }
}
