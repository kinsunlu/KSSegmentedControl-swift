//
//  KSMainViewController.swift
//  KSSegmentedControl
//
//  Created by kinsun on 2018/8/15.
//  Copyright © 2018年 kinsun. All rights reserved.
//

import UIKit

class KSMainViewController: UIViewController, UIScrollViewDelegate {
    
    override func loadView() {
        super.loadView();
        let view = KSMainView.init(frame: self.view.frame);
        view._scrollView.delegate = self;
        self.view = view;
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let view : KSMainView = self.view as! KSMainView;
        view._segmented.scrollViewDidScroll(scrollView: scrollView);
    }
}

