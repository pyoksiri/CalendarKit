import UIKit
import DateToolsSwift
import Neon

protocol EventViewDelegate: class {
  func eventViewDidTap(_ eventView: EventView)
  func eventViewDidLongPress(_ eventview: EventView)
}

public protocol EventDescriptor: class {
  var datePeriod: TimePeriod {get}
  var text: String {get}
  var attributedText: NSAttributedString? {get}
  var font : UIFont {get}
  var color: UIColor {get}
  var textColor: UIColor {get}
  var backgroundColor: UIColor {get}
  var frame: CGRect {get set}
}

open class EventView: UIView {

  weak var delegate: EventViewDelegate?
  public var descriptor: EventDescriptor?

  public var color = UIColor.lightGray

  var contentHeight: CGFloat {
    return textView.height
  }

  lazy var textView: UITextView = {
    let view = UITextView()
    view.isUserInteractionEnabled = false
    view.backgroundColor = .clear
    view.isScrollEnabled = false
    return view
  }()
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

  lazy var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
  lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    clipsToBounds = true
    [tapGestureRecognizer, longPressGestureRecognizer].forEach {addGestureRecognizer($0)}

    color = tintColor
    addSubview(textView)
    addSubview(backgroundView)
  }

  func updateWithDescriptor(event: EventDescriptor) {
    if let attributedText = event.attributedText {
      textView.attributedText = attributedText
    } else {
      textView.text = event.text
      textView.textColor = event.textColor
      textView.font = event.font
    }
    descriptor = event
    backgroundColor = UIColor.clear
    color = event.color
    backgroundView.backgroundColor = event.backgroundColor
    backgroundView.layer.masksToBounds = true
    let path = UIBezierPath(roundedRect:backgroundView.bounds,
                            byRoundingCorners:[.topRight, .bottomRight],
                            cornerRadii: CGSize(width: 2.5, height:  2.5))
    let maskLayer = CAShapeLayer()
    maskLayer.path = path.cgPath
    backgroundView.layer.mask = maskLayer
    setNeedsDisplay()
    setNeedsLayout()
  }

  @objc func tap() {
    delegate?.eventViewDidTap(self)
  }

  @objc func longPress() {
    delegate?.eventViewDidLongPress(self)
  }

  override open func draw(_ rect: CGRect) {
    super.draw(rect)
    let context = UIGraphicsGetCurrentContext()
    context!.interpolationQuality = .none
    context?.saveGState()
    context?.setStrokeColor(color.cgColor)
    context?.setLineWidth(4)
    context?.translateBy(x: 0, y: 0.0)
    let x: CGFloat = 0
    let y: CGFloat = 0
    context?.beginPath()
    context?.move(to: CGPoint(x: x, y: y))
    context?.addLine(to: CGPoint(x: x, y: (bounds).height))
    context?.strokePath()
    context?.restoreGState()
  }

  override open func layoutSubviews() {
    super.layoutSubviews()
    textView.fillSuperview()
    backgroundView.fillSuperview()
  }
}
