import Foundation
import UIKit
import SnapKit

class RequestResultContainer: UIView{
    let errorLabel = UILabel()
    let wordView = UILabel()
    let translationsView = UITextView()
    let loading = UIActivityIndicatorView()
    let groupLabel = FilledView()
    let contentView = UIView()

    init(){
        super.init(frame: .zero)
        backgroundColor = .white
        isUserInteractionEnabled = true
        translationsView.isEditable = false
        wordView.isUserInteractionEnabled = false
        layer.cornerRadius = 25
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.3

        wordView.textAlignment = .left
        wordView.textColor = #colorLiteral(red: 0.3215686275, green: 0.7843137255, blue: 0.7647058824, alpha: 1)
        wordView.font = UIFont.preferredFont(forTextStyle: .largeTitle)

        translationsView.font = UIFont.preferredFont(forTextStyle: .headline)
        translationsView.textColor = #colorLiteral(red: 0.4509803922, green: 0.4509803922, blue: 0.4509803922, alpha: 1)

        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = layer.cornerRadius

        addSubview(contentView)
        contentView.addSubviews(translationsView, wordView, loading, errorLabel, groupLabel)
        contentView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }

        errorLabel.snp.makeConstraints{ make in
            make.top.equalToSuperview().inset(40)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalToSuperview().dividedBy(10)
        }

        wordView.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
            make.top.equalToSuperview().offset(15)
            make.height.equalToSuperview().dividedBy(10)
        }
        translationsView.snp.remakeConstraints{make in
            make.left.right.equalTo(wordView)
            make.right.equalTo(wordView).inset(80)
            make.top.equalTo(wordView.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-100)
        }
        loading.snp.remakeConstraints{ make in
            make.centerX.top.equalToSuperview()
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(5)
        }
        groupLabel.snp.makeConstraints{ make in
            make.right.top.equalToSuperview()
            make.width.equalToSuperview().dividedBy(4)
            make.height.equalTo(groupLabel.snp.width).dividedBy(1.8)
        }

        loading.activityIndicatorViewStyle = .gray
    }

    func make(visible: UIView...){
        for view in contentView.subviews {
            view.isHidden = !visible.contains(view)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(_ state: StateToShow){
        switch state {
        case .loading:
            make(visible: loading)
            loading.startAnimating()

        case .translated(let word, let translations):
            if translations.isEmpty{
                make(visible: errorLabel)
                errorLabel.text = "No translation"
            }
            else{
                make(visible: wordView, translationsView)
                wordView.text = word
                translationsView.text = translations.joined(separator: "\n")
            }

        case .alreadyInDatabase(let word):
            make(visible: wordView, translationsView, groupLabel)
            wordView.text = word.text
            translationsView.text = word.allTranslations.joined(separator: "\n")
            groupLabel.label.text = word.folder.descriprion
            groupLabel.color = word.folder.color

        case .networkError:
            make(visible: errorLabel)
            errorLabel.text = "Network error"

        case .addedForLater(let word):
            make(visible: wordView)
            wordView.text = word

        case .added(let word):
            make(visible: wordView, translationsView)
            wordView.text = word.text
            translationsView.text = word.allTranslations.joined(separator: "\n")

        case .empty:
            return
        }
    }
}

class AddToDatabaseButton: UIButton{

    private let colours = [#colorLiteral(red: 0, green: 0.8980392157, blue: 0.6039215686, alpha: 1).cgColor, #colorLiteral(red: 0, green: 0.7882352941, blue: 0.8392156863, alpha: 1).cgColor ]
    private let gradient: CAGradientLayer = CAGradientLayer()

    override open var isEnabled : Bool {
        willSet{
            if newValue == false {
                gradient.isHidden = true
                layer.borderWidth = 5
            }
            else{
                gradient.isHidden = false
                layer.borderWidth = 0
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradient.frame = self.bounds

        if frame.height > frame.width { // compact form
            self.layer.cornerRadius = 25
            gradient.cornerRadius   = 25
        } else {                        // regular form
            gradient.cornerRadius = frame.height/2
            self.layer.cornerRadius = frame.height/2
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel?.lineBreakMode = .byWordWrapping
        setTitleColor(#colorLiteral(red: 0, green: 0.7882352941, blue: 0.8392156863, alpha: 1), for: UIControlState.disabled)
        setTitleColor(.black, for: UIControlState.normal )
        setTitle("Add to Dictionary", for: .normal)
        setTitle("Added", for: .disabled)

        layer.borderColor = colours[0] // border will only be visible when disabled
        gradient.colors = colours
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x:1, y: 0.5)
        self.layer.insertSublayer(gradient, at: 0)  //background for active state
        backgroundColor = .white        //background for inactive state
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


