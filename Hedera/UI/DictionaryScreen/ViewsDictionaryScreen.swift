import Foundation
import UIKit
import SnapKit
import ReactiveSwift
import ReactiveCocoa

class TopPart: UIView{
    init(_ view: DictionarySearch) {
        super.init(frame: .zero)
        self.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.9921568627, blue: 0.9921568627, alpha: 1)
        self.layer.shadowRadius = 3
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        addSubview(view)

        view.snp.makeConstraints{ make in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(16, 20, 16, 20))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension DictionarySearch: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.leftView = nil
        textField.placeholder = nil
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        textField.leftView = imageView
        textField.placeholder = "search"
    }
}


class DictionarySearch: UITextField{
    private let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 5);
    private let imageView: UIImageView

    override init(frame: CGRect) {
        let image =  UIImage(named: "SearchIcon")!
        imageView = UIImageView(image: image)
        super.init(frame: frame)
        clearButtonMode = .whileEditing
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 7.0
        self.layer.borderWidth = 0.5
        self.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
        textColor = .black
        backgroundColor = .white
        self.leftViewMode = .unlessEditing
        imageView.contentMode = .scaleAspectFit
        self.leftView = imageView
        placeholder = "search"
        self.delegate = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = frame.height/2
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return placeholderRect(forBounds: bounds)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let image = leftViewRect(forBounds: bounds)
        return CGRect(x: image.maxX,
                      y: 0,
                      width: bounds.width - image.width,
                      height: bounds.height)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let imageSizeMultiplier = CGFloat(0.5)
        let verticalInset = (1-imageSizeMultiplier)*bounds.height/2
        let imageSide = bounds.height*imageSizeMultiplier
        return CGRect(x: 5,
                      y: verticalInset,
                      width: imageSide,
                      height: imageSide)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
    
class DictionaryCollectionView: UICollectionView{
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        allowsMultipleSelection = true
        contentInset = UIEdgeInsets(top: 23, left: 10, bottom: 10, right: 10)
        register(DictionaryCellView.self, forCellWithReuseIdentifier: "Cell")
        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class DictionaryCellView: UICollectionViewCell{
    private let cornerRadius = CGFloat(14.0)
    private let wordLabel = UILabel()
    private let translationLabel = UILabel()
    private let allTranslations = UITextView()
    private let colorCorner = FilledView()
    private var word : Word!

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubviews(wordLabel,
                                translationLabel,
                                allTranslations,
                                colorCorner)

        setContentViewAppearance()
        setSubviewsAppearance()
    }

    func setContentViewAppearance() {
        backgroundColor = .white

        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true

        //set cells shadow
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 6.0
    }

    func setSubviewsAppearance(){
        // Word itself
        wordLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        wordLabel.textColor = #colorLiteral(red: 0.537254902, green: 0.7294117647, blue: 0.9058823529, alpha: 1)
        wordLabel.textAlignment = .center
        wordLabel.adjustsFontSizeToFitWidth = true

        // Best translation on compact cell
        translationLabel.font = UIFont.preferredFont(forTextStyle: .body)
        translationLabel.textColor = .black
        translationLabel.textAlignment = .center

        // Expanded cell translations
        allTranslations.isHidden = true
        allTranslations.isUserInteractionEnabled = false
        allTranslations.font = UIFont.preferredFont(forTextStyle: .body)
    }

    func configure(_ viewModel: DictionaryEntety){
        switch viewModel {
        case .regular(let word):
            wordLabel.text = word.text
            translationLabel.text = word.bestTranslation
            colorCorner.label.text = word.folder.descriprion
            colorCorner.color = word.folder.color
            self.word = word
        case .waitng(let word):
            wordLabel.text = word
            colorCorner.label.text = ""
            colorCorner.color = UIColor.blue
            translationLabel.text = "waiting"
        }
    }

    override func layoutSubviews() {

        colorCorner.snp.remakeConstraints{ make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalTo(contentView.snp.width).dividedBy(4)
        }

        wordLabel.snp.remakeConstraints{make in
            make.left.equalTo(self.contentView).offset(5)
            make.right.equalTo(self.contentView).offset(-5)
            make.top.equalTo(colorCorner.snp.bottom).offset(-5)
            make.height.equalTo(contentView.snp.width).dividedBy(5)
        }

        if isExpanded {
            setExpandedTranslations()
        }
        else{
            setSingleTranslation()
        }

        super.layoutSubviews()
    }

    public var isExpanded : Bool {
        get {
            return bounds.height > bounds.width * 1.3
        }
    }

    func setSingleTranslation(){
        translationLabel.isHidden = false
        allTranslations.isHidden = true

        translationLabel.snp.remakeConstraints{make in
            make.left.equalTo(self.contentView).offset(5)
            make.right.equalTo(self.contentView).offset(-5)
            make.top.equalTo(wordLabel.snp.bottom).offset(5)
            make.height.equalTo(16)
        }
    }

    func setExpandedTranslations(){
        allTranslations.text = word.allTranslations.joined(separator: "\n")

        translationLabel.isHidden = true
        allTranslations.isHidden = false

        allTranslations.snp.remakeConstraints{ make in
            make.left.equalTo(self.contentView).offset(5)
            make.right.equalTo(self.contentView).offset(-5)
            make.top.equalTo(wordLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public func ceil(_ a: Int, _ b: Int ) -> Int {
    let resultOfDivision = Double(a)/Double(b)
    let roundedResult = Int(resultOfDivision)
    if Double(roundedResult) < resultOfDivision {
        return roundedResult + 1
    }
    else{
        return roundedResult
    }
}

class DictionaryCollectionLayout: UICollectionViewLayout{
    private var numberOfColumns = 2
    private var numberOfRows = 0
    private var cellPadding: CGFloat = 6
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    fileprivate var contentHeight: CGFloat = 0
    let expandedCells = MutableProperty<[Int]>([])

    public func expandCell(at index: Int) {
        expandedCells.value.append(index)
    }

    func colapseCell(at index: Int) {
        expandedCells.value.remove(element: index)
    }

    func cellHeight(forIndex index: Int) -> CGFloat {
        if expandedCells.value.contains(index){
            return columnWidth * 2
        }
        else{
            return columnWidth
        }
    }

    override init() {
        super.init()
        expandedCells.signal.observeResult{_ in self.invalidateLayout()}
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var contentWidth: CGFloat {
        guard let collectionView = self.collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    private var columnWidth: CGFloat{
        return contentWidth / CGFloat(numberOfColumns)
    }

    override func prepare() {
        cache = [UICollectionViewLayoutAttributes]()
        guard let collectionView = self.collectionView else {
            return
        }

        numberOfRows = ceil((collectionView.numberOfItems(inSection: 0) + expandedCells.value.count), numberOfColumns)

        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)

        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {

            let indexPath = IndexPath(item: item, section: 0)

            let height = cellHeight(forIndex: item)
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)

            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height

            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
        super.prepare()
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter{$0.frame.intersects(rect)}
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
