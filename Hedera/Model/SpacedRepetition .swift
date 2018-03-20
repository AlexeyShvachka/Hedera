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

class SpacedRepetition: PhaseManager{
    public func get(for word: Word, wasGuessed: Bool) -> (Date, Phase) {
        let newFolder = wasGuessed ? word.folder.next : word.folder.previous
        return (.now + newFolder.interval, newFolder)
    }

    public let newWordDue: Date = .now
    public let newWordPhase: Phase = .fresh
}
