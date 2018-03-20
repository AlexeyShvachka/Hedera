import Foundation
import UIKit

struct Word {
    let text : String
    let added: Date
    let willShow: Date
    let folder: Phase
    let bestTranslation: String
    let translationsProvider: ()->[String]
    var allTranslations:[String] {
        get{
            return self.translationsProvider()
        }
    }

    private init(_ word: String = ""){
        self.text = word
        self.added = .today
        self.willShow = .today
        self.folder = .fresh
        self.bestTranslation = ""
        translationsProvider = {[]}
    }
    public static func mock(from word: String) -> Word{
        return Word(word)
    }
    public static var empty: Word {
        return Word()
    }
}

extension Word: Equatable{
    static public func ==(lhs: Word, rhs: Word) -> Bool {
        return lhs.text == rhs.text
    }
}

struct Feedback : Codable {
    let word: String
    let isGuessed: Bool
    let time: Date
}

public enum Phase : Int16, Codable{
    case fresh = 1
    case seen
    case midle
    case advanced
    case learned

    var descriprion: String {
        switch self {
        case .fresh:
            return "0%"
        case .seen:
            return "25%"
        case .midle:
            return "50%"
        case .advanced:
            return "75%"
        case .learned:
            return "✓"
        }
    }

    var color: UIColor {
        switch self {
        case .fresh:
            return #colorLiteral(red: 0.737254902, green: 0.8392156863, blue: 0.7921568627, alpha: 1)
        case .seen:
            return #colorLiteral(red: 0.4941176471, green: 0.8705882353, blue: 0.6901960784, alpha: 1)
        case .midle:
            return #colorLiteral(red: 0.5137254902, green: 0.7843137255, blue: 0.8117647059, alpha: 1)
        case .advanced:
            return #colorLiteral(red: 0.4509803922, green: 0.6078431373, blue: 0.7490196078, alpha: 1)
        case .learned:
            return #colorLiteral(red: 0.231372549, green: 0.4274509804, blue: 0.6078431373, alpha: 1)
        }
    }
}

struct DataModel: Codable {
    struct Head : Codable {}

    struct Text : Codable {
        let text: String
    }

    struct Tr : Codable {
        let text: String
        let pos: String
        let syn: [Text]?
        let mean: [Text]?
        let ex: [AltTranslation]?
    }

    struct AltTranslation: Codable{
        let text: String
        let tr: [Text]?
    }

    struct Def: Codable{
        let text: String
        let pos: String
        let tr: [Tr]?
    }

    let head: Head
    let def: [Def]?
}

extension DataModel {
    var isEmpty: Bool {
        get {
            return def == nil || def!.isEmpty
        }
    }
}


