import Foundation
import ReactiveSwift

fileprivate extension Phase{
    var interval : TimeInterval {
        switch self {
        case .fresh:
            return 1.days
        case .seen:
            return 3.days
        case .midle:
            return 1.weeks
        case .advanced :
            return 2.weeks
        case .learned:
            return .infinity
        }
    }
}

protocol PhaseManager {
    func get(for word: Word, wasGuessed: Bool) -> (Date, Phase)
    var newWordDue: Date {get}
    var newWordPhase: Phase {get}
}

class SpacedRepetition: PhaseManager{
    public func get(for word: Word, wasGuessed: Bool) -> (Date, Phase) {
        let newFolder = wasGuessed ? word.folder.next : word.folder.previous
        return (.now + newFolder.interval, newFolder)
    }
    //FIX: change to .tommorow for releases
    public let newWordDue: Date = .now
    public let newWordPhase: Phase = .fresh
}
