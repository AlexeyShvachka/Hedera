import UIKit
import SnapKit
import ReactiveSwift
import ReactiveCocoa

class ShowTranslationButton: RoundButton{
    let gradient: CAGradientLayer = CAGradientLayer()
    let colours = [#colorLiteral(red: 0, green: 0.8980392157, blue: 0.6039215686, alpha: 1).cgColor, #colorLiteral(red: 0, green: 0.7882352941, blue: 0.8392156863, alpha: 1).cgColor ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitle("Show translation", for: .normal)
        self.backgroundColor = .clear
        gradient.colors = colours
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x:1, y: 0.5)
        self.layer.addSublayer(gradient)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = self.bounds
        gradient.cornerRadius = frame.height/2
    }
}

class WordContainer: UIView {
    private let wordLabel = UILabel()
    private let groupLabel = FilledView()
    private let contentView = UIView()
    let word: MutableProperty<Word?>
    override init(frame: CGRect) {
        word = MutableProperty(.none)
        super.init(frame: frame)
        backgroundColor = .white
        //shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.07
        layer.shadowRadius = 7.0
        //roundCorner
        layer.cornerRadius = 20
        contentView.layer.cornerRadius = layer.cornerRadius
        contentView.layer.masksToBounds = true
        //word
        wordLabel.textAlignment = .center
        wordLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        wordLabel.textColor = #colorLiteral(red: 0.4509803922, green: 0.4509803922, blue: 0.4509803922, alpha: 1)
        //bind to viewModel
        wordLabel.reactive.text <~ word.map{$0?.text ?? ""}
        groupLabel.label.reactive.text <~ word.map{$0?.folder.descriprion ?? ""}
        groupLabel.reactive.color <~ word.map{$0?.folder.color ?? UIColor.black}

        //set hierarchy
        addSubview(contentView)
        contentView.addSubviews(wordLabel,
                                groupLabel)

        //set constraints
        contentView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        wordLabel.snp.makeConstraints{ make in
            make.width.centerY.centerX.equalToSuperview()
            make.height.equalTo(55)
        }
        groupLabel.snp.makeConstraints{ make in
            make.right.top.equalToSuperview()
            make.height.equalToSuperview().dividedBy(3)
            make.width.equalToSuperview().dividedBy(4)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TranslationContainer: UIView{
    public let textView = UITextView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(textView)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 0.07
        self.layer.shadowRadius = 7.0
        self.layer.cornerRadius = 20
        backgroundColor = .white
        textView.isEditable = false
        textView.font = UIFont.preferredFont(forTextStyle: .headline)
        textView.textColor = #colorLiteral(red: 0.4509803922, green: 0.4509803922, blue: 0.4509803922, alpha: 1)
        textView.snp.makeConstraints{ make in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(30, 20, 20, 20))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

