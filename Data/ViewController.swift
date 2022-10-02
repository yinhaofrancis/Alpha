//
//  ViewController.swift
//  Data
//
//  Created by hao yin on 2022/5/6.
//

import UIKit
import Ammo
class ViewController: UIViewController {
   
    let ctx = try! RenderContext(size: CGSize(width: 100, height: 100), scale: 3,reverse: true);
   
    @IBOutlet var de:testPd!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.de.headerHeight = 128
        self.de.indicateHeight = 64
        self.de.offset = 64
        self.pager.resize()
        self.pager.mainScrollView.contentInsetAdjustmentBehavior = .always
        self.navigationController?.hidesBarsOnTap = true
        self.pager.mainScrollView.refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 44, height: 44), primaryAction: UIAction(handler: { [weak self] i in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                self?.pager.mainScrollView.refreshControl?.endRefreshing()
            }
        }))
    }
    @IBOutlet weak var pager: YHPageView!
    @IBAction public func reload(){
        self.de.indicateHeight = 128
        self.de.headerHeight = 300
        self.de.offset = 64
        
        UIView .animate(withDuration: 0.5) {
            self.pager.resize()
            self.pager.mainScrollView.layoutIfNeeded()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            self.de.headerHeight = 128
            self.de.indicateHeight = 64
            self.de.offset = 64
            
            UIView .animate(withDuration: 0.5) {
                self.pager.resize()
                self.pager.mainScrollView.layoutIfNeeded()
            }
        }
       
    }
}

public class testp:NSObject,YHPageViewPage,UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = UIColor(white: 1 - CGFloat(indexPath.row) / 100.0, alpha: 1)
        return cell
    }
    
    public var pageView: YHPageView?
    

    lazy var table: UITableView = {
        let t = UITableView(frame: .zero, style: .insetGrouped)
//        t.contentInset = UIEdgeInsets(top: 250, left: 0, bottom: 250, right: 0)
        t.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        t.dataSource = self
        return t
    }()
    
    
    lazy var lsview:UIScrollView  = {
        let v = UITextView()
        v.text = "sdlfaskdf asfdhaksdf asdfaskdf asdf jasdf asjd faskdf askd fajskdf hasjkdf askdf asdjkf askdfha sjkdfaskdfh ajksdf jaksdf ajks ajksfjksdf aksdf aksdf alsjdf hajksdf aksdfh jaskdf ksjadfh akjlsdf jkasdhf kjasdf ksadf ajklsdhf jslakdf kjsdhsljkfhaskdfh asjkdf hasjkdf haskjdfhasdfa sjkdfhasdf sadfh askjdf asdfh asdjkfh askdfh asdh akjlsdf jkasdhf kjasdf ksadf ajklsdhf jslakdf kjsdhsljkfhaskdfh asjkdf hasjkdf haskjdfhasdfa sjkdfhasdf sadfh askjdf asdfh asdjkfh askdfh asdh asldf alsfhljksdfh klajsfh aksdfh sadjhf ajks askjldfh akjsdfhasdf sjakdfh asjkdf sajkdfh asjdkfh sjdf ajskdf sjkdh skjad jaksdf jsdkf jskdhf jsakdf ajks jksdf skd jksaf lkasjdhf ksldh sljak lk ajksdhf lkjsadhfl ksadhf ksd jskh sjkadh jks hfskjh ajslkdfh akljsdhf kjsdfajksdf ajksd jlskh fjlsakdfh lsakjdh sakjdf kajsdh lsak akjlsdf jkasdhf kjasdf ksadf ajklsdhf jslakdf kjsdhsljkfhaskdfh asjkdf hasjkdf haskjdfhasdfa sjkdfhasdf sadfh askjdf asdfh asdjkfh askdfh asdh asldf alsfhljksdfh klajsfh aksdfh sadjhf ajks askjldfh akjsdfhasdf sjakdfh asjkdf sajkdfh asjdkfh sjdf ajskdf sjkdh skjad jaksdf jsdkf jskdhf jsakdf ajks jksdf skd jksaf lkasjdhf ksldh sljak lk ajksdhf lkjsadhfl ksadhf ksd jskh sjkadh jks hfskjh ajslkdfh akljsdhf kjsdfajksdf ajksd jlskh fjlsakdfh lsakjdh sakjdf kajsdh lsak akjlsdf jkasdhf kjasdf ksadf ajklsdhf jslakdf kjsdhsljkfhaskdfh asjkdf hasjkdf haskjdfhasdfa sjkdfhasdf sadfh askjdf asdfh asdjkfh askdfh asdh asldf alsfhljksdfh klajsfh aksdfh sadjhf ajks askjldfh akjsdfhasdf sjakdfh asjkdf sajkdfh asjdkfh sjdf ajskdf sjkdh skjad jaksdf jsdkf jskdhf jsakdf ajks jksdf skd jksaf lkasjdhf ksldh sljak lk ajksdhf lkjsadhfl ksadhf ksd jskh sjkadh jks hfskjh ajslkdfh akljsdhf kjsdfajksdf ajksd jlskh fjlsakdfh lsakjdh sakjdf kajsdh lsak akjlsdf jkasdhf kjasdf ksadf ajklsdhf jslakdf kjsdhsljkfhaskdfh asjkdf hasjkdf haskjdfhasdfa sjkdfhasdf sadfh askjdf asdfh asdjkfh askdfh asdh asldf alsfhljksdfh klajsfh aksdfh sadjhf ajks askjldfh akjsdfhasdf sjakdfh asjkdf sajkdfh asjdkfh sjdf ajskdf sjkdh skjad jaksdf jsdkf jskdhf jsakdf ajks jksdf skd jksaf lkasjdhf ksldh sljak lk ajksdhf lkjsadhfl ksadhf ksd jskh sjkadh jks hfskjh ajslkdfh akljsdhf kjsdfajksdf ajksd jlskh fjlsakdfh lsakjdh sakjdf kajsdh lsak akjlsdf jkasdhf kjasdf ksadf ajklsdhf jslakdf kjsdhsljkfhaskdfh asjkdf hasjkdf haskjdfhasdfa sjkdfhasdf sadfh askjdf asdfh asdjkfh askdfh asdh asldf alsfhljksdfh klajsfh aksdfh sadjhf ajks askjldfh akjsdfhasdf sjakdfh asjkdf sajkdfh asjdkfh sjdf ajskdf sjkdh skjad jaksdf jsdkf jskdhf jsakdf ajks jksdf skd jksaf lkasjdhf ksldh sljak lk ajksdhf lkjsadhfl ksadhf ksd jskh sjkadh jks hfskjh ajslkdfh akljsdhf kjsdfajksdf ajksd jlskh fjlsakdfh lsakjdh sakjdf kajsdh lsak akjlsdf jkasdhf kjasdf ksadf ajklsdhf jslakdf kjsdhsljkfhaskdfh asjkdf hasjkdf haskjdfhasdfa sjkdfhasdf sadfh askjdf asdfh asdjkfh askdfh asdh asldf alsfhljksdfh klajsfh aksdfh sadjhf ajks askjldfh akjsdfhasdf sjakdfh asjkdf sajkdfh asjdkfh sjdf ajskdf sjkdh skjad jaksdf jsdkf jskdhf jsakdf ajks jksdf skd jksaf lkasjdhf ksldh sljak lk ajksdhf lkjsadhfl ksadhf ksd jskh sjkadh jks hfskjh ajslkdfh akljsdhf kjsdfajksdf ajksd jlskh fjlsakdfh lsakjdh sakjdf kajsdh lsak asldf alsfhljksdfh klajsfh aksdfh sadjhf ajks askjldfh akjsdfhasdf sjakdfh asjkdf sajkdfh asjdkfh sjdf ajskdf sjkdh skjad jaksdf jsdkf jskdhf jsakdf ajks jksdf skd jksaf lkasjdhf ksldh sljak lk ajksdhf lkjsadhfl ksadhf ksd jskh sjkadh jks hfskjh ajslkdfh akljsdhf kjsdfajksdf ajksd jlskh fjlsakdfh lsakjdh sakjdf kajsdh lsakdfh skdjfh skdf hsjdkf kslajd hjaksdh jksadfhk sladf jksd skd kj"
        v.font = UIFont .systemFont(ofSize: 40)
        v.isEditable = false
        return v
    }()
    
    public var view: UIView{
        return table
    }
    
    public var scrollView: UIScrollView{
        return table
    }
    
    
}

public class im:UIButton,YHPageViewIndicate{
    public func indicateOffset(offset: CGFloat) {
        self .setTitle("\(offset)", for: .normal)
        self.addTarget(self, action: #selector(handleTouch), for: .touchUpInside)
    }
    
    public var pageView: YHPageView?
    
    public var view: UIView{
        return self
    }
    @objc func handleTouch(){
        self.pageView?.scrollToIndex(index: Int(arc4random()) % 10 , animation: true)
    }
    
}

public class testPd:NSObject,YHPageViewDelegate{
    public func numberOfPage() -> NSInteger {
        return 10;
    }
    public func pageOfIndex(index: Int) -> YHPageViewPage {
        testp()
    }
    public func heightOfHeaderView() -> NSInteger {
        return self.headerHeight
    }
    public func heightOfIndicateView() -> NSInteger {
        return self.indicateHeight
    }
    public func headerScrollOffset() -> NSInteger {
        return offset
    }
    public var headerHeight:Int  = 128
    public var indicateHeight:Int = 64
    public var offset:Int = 64
    public func headerView() -> UIView {
        let l = UIView()

        l.backgroundColor = UIColor.purple

        return l
    }
    let bt:im = {
        let i = im();
        i.backgroundColor = UIColor.black;
        return i
    }()
    public func indicateView() -> YHPageViewIndicate {
        return bt
    }
}
