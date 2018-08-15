//
//  KSMainView.swift
//  KSSegmentedControl
//
//  Created by kinsun on 2018/8/15.
//  Copyright © 2018年 kinsun. All rights reserved.
//

import UIKit

class KSMainView: UIView {
    
    public private (set) var _scrollView : UIScrollView!
    public private (set) var _segmented : KSSegmentedControl!
    
    private var _labels : [UILabel]!
    private weak var _topBar : UIView!
    private weak var _line : UIView!

    override init(frame: CGRect) {
        super.init(frame: frame);
        __initView();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func __initView() {
        let whiteColor = UIColor.white
        backgroundColor = whiteColor;
        
        let items : [NSString] = ["列表", "年历", "月历", "日历"];
        let count = items.count;
        let bounds = self.bounds;
        
        let scrollView : UIScrollView = UIScrollView.init(frame: bounds);
        scrollView.isPagingEnabled = true;
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.contentSize = CGSize(width: bounds.size.width*CGFloat(count), height: 0.0);
        addSubview(scrollView);
        _scrollView = scrollView;
        
        let color = UIColor.init(red: 255.0/255.0, green: 111.0/255.0, blue: 111.0/255.0, alpha: 1.0);
        let font : UIFont = UIFont.boldSystemFont(ofSize: 280.0);
        
        var labels : [UILabel] = NSMutableArray.init() as! [UILabel];
        for i in 0..<count {
            let label = UILabel.init();
            label.font = font;
            label.textAlignment = NSTextAlignment.center;
            label.textColor = color;
            label.text = NSNumber.init(value: i+1).stringValue;
            scrollView.addSubview(label);
            labels.append(label);
        }
        _labels = NSArray.init(array: labels) as! [UILabel];
        
        let topBar = UIView.init();
        topBar.backgroundColor = whiteColor;
        addSubview(topBar);
        _topBar = topBar;
        
        let line = UIView.init();
        line.backgroundColor = UIColor.init(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0);
        topBar.addSubview(line);
        _line = line;
        
        let segmented = KSSegmentedControl.init(frame: CGRect.zero, items: items);
        segmented.normalTextColor = color;
        segmented.cornerRadius = 6.0;
        weak var weakSelf = self;
        segmented._didClickItem = { (index) -> Void in
            let k_scrollView = weakSelf?._scrollView;
            let x = k_scrollView!.frame.size.width*CGFloat(index);
            k_scrollView?.setContentOffset(CGPoint(x:x , y: 0.0), animated: true);
        };
        topBar.addSubview(segmented);
        _segmented = segmented;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        let count = _labels.count;
        let CGCount = CGFloat(count);
        
        let bounds = self.bounds;
        let windowWidth = bounds.size.width;
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height;
        _scrollView.frame = bounds;
        _scrollView.contentSize = CGSize(width: windowWidth*CGCount, height: 0.0);
        
        var viewX: CGFloat = 0.0;
        var viewY: CGFloat = 0.0;
        var viewW: CGFloat = windowWidth;
        var viewH: CGFloat = bounds.size.height;
        for i in 0..<count {
            viewX=viewW*CGFloat(i);
            let label = _labels[i];
            label.frame = CGRect.init(x: viewX, y: viewY, width: viewW, height: viewH);
        }
        
        viewX=0.0; viewH=statusBarHeight+44.0;
        _topBar.frame = CGRect.init(x: viewX, y: viewY, width: viewW, height: viewH);
        
        viewW=66.5*CGCount; viewH=38.0; viewX=(windowWidth-viewW)*0.5; viewY=statusBarHeight+(44.0-viewH)*0.5;
        _segmented.frame = CGRect.init(x: viewX, y: viewY, width: viewW, height: viewH);
        
        viewW=windowWidth;viewH=0.5;viewX=0.0;viewY=_topBar.frame.size.height-viewH;
        _line.frame = CGRect.init(x: viewX, y: viewY, width: viewW, height: viewH);
    }
}
