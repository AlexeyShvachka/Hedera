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

class UserInput: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 5);

    override init(frame: CGRect) {
        super.init(frame: frame)
        clearButtonMode = .whileEditing
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 0.07
        self.layer.shadowRadius = 7.0
        self.layer.borderWidth = 0.5
        self.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
        autocorrectionType = .no
        autocapitalizationType = .none
        placeholder = "Czech word to translate"
        textColor = .black
        backgroundColor = .white
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = frame.height/2
    }


    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
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

