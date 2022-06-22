//
//  KSSegmentedControl.swift
//  KSSegmentedControl
//
//  Created by kinsun on 2018/8/15.
//  Copyright © 2018年 kinsun. All rights reserved.
//

import UIKit

open class KSSegmentedControl: UIView {
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public let items: [String]
    private let _highlightLayer = CALayer()
    private let _maskLayer = CAShapeLayer()
    private let _normalTextLayerArray: [_ItemLayer]
    private let _highlightTextLayerArray: [_ItemLayer]
    
    public init(frame: CGRect = .zero, items: [String]) {
        self.items = items
        var normalTextLayerArray = [_ItemLayer]()
        var highlightTextLayerArray = [_ItemLayer]()
        for title in items {
            let normalTextLayer = _ItemLayer()
            normalTextLayer.string = title
            normalTextLayerArray.append(normalTextLayer)
            let highlightTextLayer = _ItemLayer()
            highlightTextLayer.string = title
            highlightTextLayerArray.append(highlightTextLayer)
        }
        _normalTextLayerArray = normalTextLayerArray
        _highlightTextLayerArray = highlightTextLayerArray
        super.init(frame: frame)
        let layer = self.layer
        layer.cornerRadius = 4.0
        layer.masksToBounds = true
        let pointSize = font.pointSize
        let fontName = font.fontName as CFString
        let fontRef = CGFont(fontName)
        let normalTextColor = self.normalTextColor.cgColor
        for i in 0..<items.count {
            let normalTextLayer = normalTextLayerArray[i]
            normalTextLayer.font = fontRef
            normalTextLayer.fontSize = pointSize
            normalTextLayer.foregroundColor = normalTextColor
            layer.addSublayer(normalTextLayer)
            
            let highlightTextLayer = highlightTextLayerArray[i]
            highlightTextLayer.font = fontRef
            highlightTextLayer.fontSize = pointSize
            _highlightLayer.addSublayer(highlightTextLayer)
        }
        _highlightLayer.backgroundColor = normalTextColor
        _highlightLayer.mask = _maskLayer
        layer.addSublayer(_highlightLayer)
    }
    
    open override func layoutSublayers(of layer: CALayer) {
        _highlightLayer.frame = layer.bounds
        let size = layer.bounds.size
        let count = items.count
        var viewX = CGFloat(0.0)
        let viewH = font.lineHeight
        let viewY = (size.height-viewH)*0.5
        let viewW = floor(size.width/CGFloat(count))
        
        for i in 0..<count {
            let normalTextLayer = _normalTextLayerArray[i]
            let highlightTextLayer = _highlightTextLayerArray[i]
            let rect = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
            normalTextLayer.frame = rect
            highlightTextLayer.frame = rect
            viewX = rect.maxX
        }
        
        let width = viewW
        let height = size.height
        let radius = cornerRadius
        let pi = CGFloat.pi
        
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle:pi, endAngle: -(pi*0.5), clockwise: true)
        path.addArc(withCenter: CGPoint(x: width-radius, y: radius), radius: radius, startAngle:-(pi*0.5), endAngle: 0.0, clockwise: true)
        path.addArc(withCenter: CGPoint(x: width-radius, y: height-radius), radius: radius, startAngle:0.0, endAngle: pi*0.5, clockwise: true)
        path.addArc(withCenter: CGPoint(x: radius, y: height-radius), radius: radius, startAngle:pi*0.5, endAngle: pi, clockwise: true)
        path.close()
        _maskLayer.path = path.cgPath
        
        var rect = _maskLayer.frame
        rect.size.width = width
        rect.origin.x = CGFloat(_selectedSegmentIndex)*width
        _maskLayer.frame = rect
    }
    
    public func scrollViewDidScroll(scrollView : UIScrollView!) {
        let x = scrollView.contentOffset.x
        let s = x/scrollView.contentSize.width
        let t = s*bounds.size.width
        var rect = _maskLayer.frame
        rect.origin.x = t
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        _maskLayer.frame = rect
        CATransaction.commit()
        
        let width = scrollView.bounds.size.width
        _selectedSegmentIndex = Int(ceil((x-width*0.5)/width))
    }
    
    private var _selectedSegmentIndex = 0
    
    open var selectedSegmentIndex: Int {
        set {
            guard _selectedSegmentIndex != newValue else { return }
            _selectedSegmentIndex = newValue
            var rect = _maskLayer.frame
            let t = bounds.size.width/CGFloat(items.count*newValue)
            rect.origin.x = t
            _maskLayer.frame = rect
        }
        get { _selectedSegmentIndex }
    }
    
    open var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            setNeedsLayout()
        }
        get { layer.cornerRadius }
    }
    
    open var font = UIFont.systemFont(ofSize: 17.0) {
        didSet {
            let pointSize = font.pointSize
            let fontName = font.fontName as CFString
            let fontRef = CGFont(fontName)
            for i in 0..<items.count {
                let normalTextLayer = _normalTextLayerArray[i]
                normalTextLayer.font = fontRef
                normalTextLayer.fontSize = pointSize
                
                let highlightTextLayer = _highlightTextLayerArray[i]
                highlightTextLayer.font = fontRef
                highlightTextLayer.fontSize = pointSize
            }
        }
    }
    
    open var normalTextColor = UIColor.blue {
        didSet {
            let color = normalTextColor.cgColor
            for normalTextLayer in _normalTextLayerArray {
                normalTextLayer.foregroundColor = color
            }
            _highlightLayer.backgroundColor = color
        }
    }
    
    open var highlightTextColor = UIColor.white {
        didSet {
            let color = highlightTextColor.cgColor
            for highlightTextLayer in _highlightTextLayerArray {
                highlightTextLayer.foregroundColor = color
            }
        }
    }
    
    open var didClickItemCallback : ((Int) -> Void)?
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let c = didClickItemCallback, let touch = touches.first else { return }
        let location = touch.location(in: self)
        guard bounds.contains(location) else { return }
        let index = Int(location.x/(bounds.size.width/CGFloat(items.count)))
        c(index)
    }
}

extension KSSegmentedControl {
    
    private class _ItemLayer: CATextLayer {
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override init() {
            super.init()
            isWrapped = true
            alignmentMode = .center
            contentsScale = UIScreen.main.scale
        }
        
        override init(layer: Any) {
            super.init(layer: layer)
            isWrapped = true
            alignmentMode = .center
            contentsScale = UIScreen.main.scale
        }
        
    }
    
}
