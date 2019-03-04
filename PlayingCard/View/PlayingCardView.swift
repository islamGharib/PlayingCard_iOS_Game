//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Islam Gharib on 1/24/19.
//  Copyright © 2019 Gharib. All rights reserved.
//

import UIKit

// to see the design change in the storyboard before run use -> @IBDesignable
@IBDesignable
class PlayingCardView: UIView {
    // redraw the value of these properties when they changed and redraw the layout using setNeedsDisplay(), setNeedsLayout()
    // to show the properety on the utility of the storyboard use -> @IBInspectable
    @IBInspectable
    var rank:Int = 12 {didSet{setNeedsDisplay(); setNeedsLayout()}}
    @IBInspectable
    var suit:String = "♥️" {didSet{setNeedsDisplay(); setNeedsLayout()}}
    @IBInspectable
    var isFaceUp:Bool = true {didSet{setNeedsDisplay(); setNeedsLayout()}}
    
    var faceCardScale:CGFloat = SizeRatio.faceCardImageSizeToBoundsSize{didSet{setNeedsDisplay()}}
    // handel the scale gesture recogniser
    @objc func adjustFaceCardScale(byHandlingGestureRecognizedBy recognizer:UIPinchGestureRecognizer){
        switch recognizer.state {
        case .changed,.ended:
            faceCardScale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    // centered the String of the card and adjust the font size according to the device config font
    private func centeredAttributedString(_ string:String, fontSize:CGFloat)->NSAttributedString{
        // set the font size
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        // edite the font size according to the device config font
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        
        // centered the String
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        // return the attributedString
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle,.font:font])
    }
    private var cornerString:NSAttributedString{
        return centeredAttributedString(rankString+"\n"+suit, fontSize: cornerFontSize)
    }
    
    // create 2 lables upperleftcorner and lowerrightcorner and adjust its configuration
    private lazy var upperLeftCornerLable = createCornerLable()
    private lazy var lowerRightCornerLable = createCornerLable()
    private func createCornerLable()->UILabel{
        let lable = UILabel()
        // number of lines is unlimited
        lable.numberOfLines = 0
        // add the lable to the view
        addSubview(lable)
        return lable
    }
    private func configureCornerLable(_ lable:UILabel){
        lable.attributedText = cornerString
        lable.frame.size = CGSize.zero
        lable.sizeToFit()
        // hide the lable if the card is not faceUp
        lable.isHidden = !isFaceUp
    }
    
    // change the scale and layout according to the device config
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    
    // where the view is layout invoked with the method setNeedsLayout()
    override func layoutSubviews() {
        super.layoutSubviews()
        // upperLeft lable
        configureCornerLable(upperLeftCornerLable)
        upperLeftCornerLable.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)
        
        // lowerRight lable -> translate, rotate then change the origin to the lower right corner
        configureCornerLable(lowerRightCornerLable)
        lowerRightCornerLable.transform = CGAffineTransform.identity.translatedBy(x: lowerRightCornerLable.frame.size.width, y: lowerRightCornerLable.frame.size.height).rotated(by: CGFloat.pi)
        lowerRightCornerLable.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY).offsetBy(dx: -cornerOffset, dy: -cornerOffset).offsetBy(dx: -lowerRightCornerLable.frame.size.width, dy: -lowerRightCornerLable.frame.size.height)
    }
    
    // draw pips
    private func drawPips(){
        let pipsPerRawForRank = [[0],[1],[1,1],[1,1,1],[2,2],[2,1,2],[2,2,2],[2,1,2,2],[2,2,2,2],[2,2,1,2,2],[2,2,2,2,2]]
        
        func createPipString(thatFits pipRect:CGRect)->NSAttributedString{
            let maxVerticalPipCount = CGFloat(pipsPerRawForRank.reduce(0){max($1.count, $0)})
            let maxHorizontalPipCount = CGFloat(pipsPerRawForRank.reduce(0){max($1.max() ?? 0, $0)})
            let verticalPipRowSpacing = pipRect.size.height/maxVerticalPipCount
            let attributedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attributedPipString.size().height / verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize)
            
            if probablyOkayPipString.size().width > pipRect.size.width/maxHorizontalPipCount{
                return centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize / (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            }else{
                return probablyOkayPipString
            }
        }
        
        if pipsPerRawForRank.indices.contains(rank){
            let pipsPerRow = pipsPerRawForRank[rank]
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
            let pipString = createPipString(thatFits: pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            
            for pipCount in pipsPerRow{
                switch pipCount{
                case 1:
                    pipString.draw(in: pipRect)
                case 2:
                    pipString.draw(in: pipRect.leftHalf)
                    pipString.draw(in: pipRect.rightHalf)
                default:
                    break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
    }
    
    // draw the view invoked with the method setNeedsDisplay()
    override func draw(_ rect: CGRect) {
                                // Drawing code
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        UIColor.white.setFill()
        roundedRect.fill()
        
        // draw card image
        if isFaceUp{
            if let faceCardImage = UIImage(named: rankString+suit, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection){
                faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
            }else{
                drawPips()
            }
        }
        else{
            if let cardBackImage = UIImage(named: "cardback"){
                cardBackImage.draw(in: bounds)
            }
        }
        
    /*
                                        test
        // using UIGraphics
        if let context = UIGraphicsGetCurrentContext(){
            context.addArc(center: CGPoint(x: bounds.midX, y: bounds.midY), radius: 100.0, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
            context.setLineWidth(5.0)
            UIColor.green.setFill()
            UIColor.red.setStroke()
            context.strokePath()
            context.fillPath()
        }
 
 
        // using UIBezierPath
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: 100.0, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        path.lineWidth = 5.0
        UIColor.green.setFill()
        UIColor.red.setStroke()
        path.stroke()
        path.fill()
 
    */
    }
    

}

extension PlayingCardView{
    private struct SizeRatio{
        static let cornerFontSizeToBoundsHeight:CGFloat = 0.085
        static let cornerRadiusToBoundsHeight:CGFloat = 0.06
        static let cornerOffsetToCornerRadius:CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize:CGFloat = 0.75
    }
    
    private var cornerRadius:CGFloat{
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var cornerOffset:CGFloat{
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    private var cornerFontSize:CGFloat{
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    
    private var rankString:String{
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
}

extension CGRect{
    var leftHalf:CGRect{
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    var rightHalf:CGRect{
        return CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    
    func inset(by size:CGSize)->CGRect{
        return insetBy(dx: size.width, dy: size.height)
    }
    func sized(by size:CGSize)->CGRect{
        return CGRect(origin: origin, size: size)
    }
    func zoom(by scale:CGFloat)->CGRect{
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width-newWidth)/2, dy: (height-newHeight)/2)
    }
}

extension CGPoint{
    func offsetBy(dx:CGFloat, dy:CGFloat)->CGPoint{
        return CGPoint(x: x+dx, y: y+dy)
    }
}
