//
//  AppDelegate.swift
//  KSSegmentedControl
//
//  Created by kinsun on 2018/8/15.
//  Copyright © 2018年 kinsun. All rights reserved.
//

import UIKit

@main
open class AppDelegate: UIResponder, UIApplicationDelegate {

    open lazy var window: UIWindow? = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = MainViewController()
        return window
    }()

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.makeKeyAndVisible()
        return true
    }

}

open class MainViewController: UIViewController, UIScrollViewDelegate {
    
    open override func loadView() {
        let view = _View()
        view.scrollView.delegate = self
        view.bar.segmented.didClickItemCallback = { [weak self] in
            guard let view = self?.view as? _View else { return }
            let x = view.bounds.size.width*CGFloat($0)
            view.scrollView.setContentOffset(CGPoint(x: x, y: 0.0), animated: true)
        }
        self.view = view
    }
    
    private var _isFirstLayout = true
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard _isFirstLayout, view.window != nil, view.bounds != .zero else { return }
        _isFirstLayout = false
        /// 设定启动时默认在index = 2（第三页）
        (view as? _View)?.scrollView.setContentOffset(CGPoint(x: view.bounds.width*2.0, y: 0.0), animated: false)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        (view as? _View)?.bar.segmented.scrollViewDidScroll(scrollView: scrollView)
    }
    
    @available(iOS 13.0, *)
    open override var overrideUserInterfaceStyle: UIUserInterfaceStyle {
        set { super.overrideUserInterfaceStyle = newValue }
        get { .light }
    }
    
}

extension MainViewController {
    
    private class _Bar: UIView {
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public let segmented: KSSegmentedControl = {
            let segmented = KSSegmentedControl(items: ["列表", "年历", "月历", "日历"])
            segmented.normalTextColor = UIColor(red: 255.0/255.0, green: 111.0/255.0, blue: 111.0/255.0, alpha: 1.0)
            segmented.cornerRadius = 6.0
            return segmented
        }()
        private let _line: UIView = {
            let line = UIView()
            line.backgroundColor = UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)
            line.isUserInteractionEnabled = false
            return line
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .white
            addSubview(segmented)
            addSubview(_line)
        }
        
        open var topMargin = CGFloat(0.0) {
            didSet { setNeedsLayout() }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let windowSize = bounds.size
            let windowWidth = windowSize.width
            let windowHeight = windowSize.height
            let viewW = min(CGFloat(segmented.items.count)*66.5, windowWidth-24.0)
            let viewH = CGFloat(38.0)
            segmented.frame = CGRect(x: (windowWidth-viewW)*0.5, y: (windowHeight-topMargin-viewH)*0.5+topMargin, width: viewW, height: viewH)
            _line.frame = CGRect(x: 0.0, y: windowHeight-1.0, width: windowWidth, height: 1.0)
        }
        
    }
    
    private class _View: UIView {
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public let bar: _Bar
        public let scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.isPagingEnabled = true
            scrollView.showsHorizontalScrollIndicator = false
            return scrollView
        }()
        private let _labels: [UILabel]

        override init(frame: CGRect) {
            let bar = _Bar()
            self.bar = bar
            let font = UIFont.boldSystemFont(ofSize: 280.0)
            let color = UIColor(red: 255.0/255.0, green: 111.0/255.0, blue: 111.0/255.0, alpha: 1.0)
            _labels = (0..<bar.segmented.items.count).map {
                let label = UILabel()
                label.font = font
                label.textAlignment = .center
                label.textColor = color
                label.text = "\($0+1)"
                return label
            }
            super.init(frame: frame)
            backgroundColor = .white
            _labels.forEach { scrollView.addSubview($0) }
            addSubview(scrollView)
            addSubview(bar)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let bounds = self.bounds
            let windowSize = bounds.size
            let windowWidth = windowSize.width
            let top: CGFloat
            if #available(iOS 11.0, *) {
                top = safeAreaInsets.top
            } else {
                top = 0.0
            }
            bar.topMargin = top
            bar.frame = CGRect(origin: .zero, size: CGSize(width: windowWidth, height: top+44.0))
            scrollView.frame = bounds

            let y = bar.frame.maxY
            let h = windowSize.height-y
            _labels.enumerated().forEach {
                $0.1.frame = CGRect(x: windowWidth*CGFloat($0.0), y: y, width: windowWidth, height: h)
            }
            scrollView.contentSize = CGSize(width: windowWidth*CGFloat(_labels.count), height: 0.0)
        }
    }
    
}
