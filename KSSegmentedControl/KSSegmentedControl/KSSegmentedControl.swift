//
//  KSSegmentedControl.swift
//  KSSegmentedControl
//
//  Created by kinsun on 2018/8/15.
//  Copyright © 2018年 kinsun. All rights reserved.
//

import UIKit

class KSSegmentedItemLayer: CATextLayer {
    override init() {
        super.init();
        isWrapped = true;
        alignmentMode = kCAAlignmentCenter;
        contentsScale = UIScreen.main.scale;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class KSSegmentedControl: UIView {
    
    public private(set) var _items : [NSString]!
    public var _didClickItem : ((_ index : Int)->Void)?
    
    private var _font : UIFont!
    private var _normalTextColor : UIColor!
    private var _highlightTextColor : UIColor!
    private var _cornerRadius : CGFloat!
    private var _selectedSegmentIndex : Int!

    private var _highlightLayer : CALayer!
    private var _maskLayer : CAShapeLayer!
    private var _normalTextLayerArray : [KSSegmentedItemLayer]!
    private var _highlightTextLayerArray : [KSSegmentedItemLayer]!
    
    public init(frame: CGRect, items: [NSString]) {
        super.init(frame: frame);
        _items = items;
        __initView();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func __initView() {
        let layer = self.layer;
        layer.masksToBounds = true;
        
        let highlightLayer = CALayer.init();
        layer.addSublayer(highlightLayer);
        _highlightLayer = highlightLayer;
        
        var normalTextLayerArray : [KSSegmentedItemLayer] = NSMutableArray.init() as! [KSSegmentedItemLayer];
        var highlightTextLayerArray : [KSSegmentedItemLayer] = NSMutableArray.init() as! [KSSegmentedItemLayer];
        for title in _items {
            let normalTextLayer = KSSegmentedItemLayer.init();
            normalTextLayer.string = title;
            layer.insertSublayer(normalTextLayer, below: highlightLayer);
            normalTextLayerArray.append(normalTextLayer);
            
            let highlightTextLayer = KSSegmentedItemLayer.init();
            highlightTextLayer.string = title;
            highlightLayer.addSublayer(highlightTextLayer);
            highlightTextLayerArray.append(highlightTextLayer);
        }
        
        _normalTextLayerArray = NSArray.init(array: normalTextLayerArray) as! [KSSegmentedItemLayer];
        _highlightTextLayerArray = NSArray.init(array: highlightTextLayerArray) as! [KSSegmentedItemLayer];
        
        let maskLayer = CAShapeLayer.init();
        highlightLayer.mask = maskLayer;
        _maskLayer = maskLayer;
        
        font = UIFont.systemFont(ofSize: 17.0);
        normalTextColor = UIColor.blue;
        highlightTextColor = UIColor.white;
        cornerRadius = 4.0;
    }
    
    override func layoutSublayers(of layer: CALayer) {
        _highlightLayer?.frame = layer.bounds;
        let size = layer.bounds.size;
        let count = _items!.count;
        var viewX: CGFloat = 0.0;
        let viewH: CGFloat = (_font?.lineHeight)!;
        let viewY: CGFloat = (size.height-viewH)*0.5;
        let viewW: CGFloat = size.width/CGFloat(count);
        
        for i in 0..<count {
            let normalTextLayer = _normalTextLayerArray[i];
            let highlightTextLayer = _highlightTextLayerArray[i];
            let rect = CGRect.init(x: viewX, y: viewY, width: viewW, height: viewH);
            normalTextLayer.frame = rect;
            highlightTextLayer.frame = rect;
            viewX = rect.maxX;
        }
        
        let width = viewW;
        let height = size.height;
        let radius = _cornerRadius!;
        let pi = CGFloat(Double.pi);
        
        let path = UIBezierPath.init();
        path.addArc(withCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle:pi, endAngle: -(pi*0.5), clockwise: true);
        path.addArc(withCenter: CGPoint(x: width-radius, y: radius), radius: radius, startAngle:-(pi*0.5), endAngle: 0.0, clockwise: true);
        path.addArc(withCenter: CGPoint(x: width-radius, y: height-radius), radius: radius, startAngle:0.0, endAngle: pi*0.5, clockwise: true);
        path.addArc(withCenter: CGPoint(x: radius, y: height-radius), radius: radius, startAngle:pi*0.5, endAngle: pi, clockwise: true);
        path.close();
        _maskLayer?.path = path.cgPath;
    }
    
    public func scrollViewDidScroll(scrollView : UIScrollView!) {
        let x = scrollView.contentOffset.x;
        let s = x/scrollView.contentSize.width;
        let t = s*frame.size.width;
        let maskLayer = _maskLayer!;
        var rect = maskLayer.frame;
        rect.origin.x = t;
        CATransaction.begin();
        CATransaction.setDisableActions(true);
        maskLayer.frame = rect;
        CATransaction.commit();
        
        let width = scrollView.frame.size.width;
        let page = Int(ceil((x-width*0.5)/width));
        _selectedSegmentIndex = page;
    }
    
    public var selectedSegmentIndex : Int! {
        set {
            if _selectedSegmentIndex != newValue {
                _selectedSegmentIndex = newValue;
                let maskLayer = _maskLayer!;
                var rect = maskLayer.frame;
                let t = frame.size.width/CGFloat(_items.count*newValue);
                rect.origin.x = t;
                maskLayer.frame = rect;
            }
        }
        get {
            return _selectedSegmentIndex;
        }
    }
    
    public var cornerRadius : CGFloat! {
        set {
            _cornerRadius = newValue;
            layer.cornerRadius = newValue;
            setNeedsDisplay();
        }
        get {
            return _cornerRadius;
        }
    }
    
    public var font : UIFont! {
        set {
            _font = newValue;
            let pointSize = font.pointSize;
            let fontName = font.fontName as CFString;
            let fontRef = CGFont.init(fontName);
            for i in 0..<_items.count {
                let normalTextLayer = _normalTextLayerArray[i];
                normalTextLayer.font = fontRef;
                normalTextLayer.fontSize = pointSize;
                
                let highlightTextLayer = _highlightTextLayerArray[i];
                highlightTextLayer.font = fontRef;
                highlightTextLayer.fontSize = pointSize;
            }
        }
        get {
            return _font;
        }
    }
    
    public var normalTextColor : UIColor! {
        set {
            _normalTextColor = newValue;
            let color =  newValue.cgColor;
            for normalTextLayer in _normalTextLayerArray {
                normalTextLayer.foregroundColor = color;
            }
            _highlightLayer.backgroundColor = color;
        }
        get {
            return _normalTextColor;
        }
    }
    public var highlightTextColor : UIColor! {
        set {
            _highlightTextColor = newValue;
            let color =  newValue.cgColor;
            for highlightTextLayer in _highlightTextLayerArray {
                highlightTextLayer.foregroundColor = color;
            }
        }
        get {
            return _highlightTextColor;
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event);
        if _didClickItem != nil {
            let touch = touches.first!;
            let location = touch.location(in: self);
            if bounds.contains(location) {
                let page = location.x/(frame.size.width/CGFloat(_items.count));
                let index = Int(page);
                _selectedSegmentIndex = index;
                _didClickItem!(index);
            }
        }
    }
}
