import Foundation
import UIKit
import SnapKit
import ReactiveSwift
import ReactiveCocoa

class Header: UILabel{
    init(_ name: String) {
        super.init(frame: .zero)
        self.text = name
        self.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.largeTitle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class FilledView: UIView {
    private let fillShape = CAShapeLayer()
    public let label = UILabel()

    public var color = UIColor.black {
        willSet {
            fillShape.fillColor = newValue.cgColor
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(fillShape)
        layer.masksToBounds = true
        label.textAlignment = .right
        self.addSubview(label)
        label.snp.makeConstraints{ make in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(0, 0, 0, 10))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let test = bounds.width/bounds.height
        let widthMultiplier : CGFloat = test
        let heightMultiplier: CGFloat = test
        let rect = CGRect(x: 0,
                          y: -(heightMultiplier-1) * bounds.height,
                          width: bounds.width * widthMultiplier,
                          height: bounds.height * heightMultiplier)
        fillShape.path = UIBezierPath(ovalIn: rect).cgPath

    }
}

class RoundButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 0.07
        self.layer.shadowRadius = 7.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = frame.height/2
    }
}

