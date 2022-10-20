//
//  ViewController.swift
//  Data
//
//  Created by hao yin on 2022/5/6.
//

import UIKit
import Ammo
import AVFoundation
import RenderImage

class tableViewController:UITableViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView .reloadData()
    }
    let filter = ImageBlur(type: .Gaussian)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "mm", for: indexPath) as! tableCell
        let u = "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01ef345bcd8977a8012099c82483d3.gif&refer=http%3A%2F%2Fimg.zcool.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1668781818&t=e339525665f0aa1e29e480b1206ec22f"
        
        tableCell.ciimage.load(url: URL(string: u)!) { [weak self] i in
            self?.filter.filter(radius: 10, image: i)
        }
        return tableCell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10000
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300;
    }
}
class tableCell: UITableViewCell {
    @IBOutlet weak var ciimage:CoreImageView!
}

class ViewController: UIViewController {
   
    let ctx = try! RenderContext(size: CGSize(width: 100, height: 100), scale: 3,reverse: true);
   
    @IBOutlet var de:testam!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBOutlet weak var pager: AMPageView!
    @IBAction public func reload(){
        self.de.height = 250
        self.de.indicate = 64
        self.pager.resize()
        UIView .animate(withDuration: 0.3) {
            self.pager.layoutIfNeeded()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            self.de.height = 128
            self.de.indicate = 44
            self.pager.resize()
            UIView .animate(withDuration: 0.3) {
                self.pager.layoutIfNeeded()
            }
        }
    }

}

let g = curry(GradientGaussMask().filter(linear:point0:point1:color:alpha:radius:image:))(false)(CGPoint(x: 0, y: 0))(CGPoint(x: 0, y: 1))(CIColor(color: UIColor.cyan))

class ViewController2: UIViewController {
   
    @IBOutlet var render: CoreImageView!
    private var radius:CGFloat = 1
    private var alpha:CGFloat = 1
    
    let tras = ImageDissolveTransition()
    let exo = ImageExposureAdjust()
    let blur = ImageBlur(type: .Gaussian)
    let k =  RemoveAlpha()
    let scale = ImageScale()
    var c:CGImage?
    var sm:CGImage?
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.render.load(url:  { i in
//            self.blur.filter(radius: 5, image: i)
//        }
//    https://img.zonghangsl.com/images/xcx/common/lucky_draw_results_winning_lottery_double.webp
//    https://www.gamesci.com.cn/assets/img/logo/logo_top.png
//    https://www.w3school.com.cn/svg/path2.svg
        self.render.load(url: URL(string: "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01ef345bcd8977a8012099c82483d3.gif&refer=http%3A%2F%2Fimg.zcool.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1668781818&t=e339525665f0aa1e29e480b1206ec22f")!) { [weak self] i in
            self?.blur.filter(radius: 10, image: i)
        }
    }
    @IBAction func changeRadius(_ sender: UISlider) {
        self.radius = CGFloat(sender.value)
        
//        self.render.image = g(self.alpha)(self.radius)(CIImage(cgImage: c!))
//        self.image()
    }
    func image(){
//        (radius: self.radius, image: )
//        self.render.image = g(self.alpha)(self.radius)(CIImage(image: UIImage(named: "i")!))
        self.render.image = g(self.alpha)(self.radius)(CIImage(cgImage: sm!))
    }
    @IBAction func changeGradient(_ sender: UISlider) {
        self.alpha = CGFloat(sender.value)
//        self.render.image = g(self.alpha)(self.radius)(CIImage(cgImage: c!))
//        self.image()
        
//        let data = Data(bytes: [SIMD2<Float>.init(x: 1, y: 0),SIMD2<Float>.init(x: 1, y: 1)], count: MemoryLayout<SIMD2<Float>>.stride * 2)
////        self.render.image = self.a.apply(extent: CGRect(x: 0, y: 0, width: 200, height: 200),roiCallback: { i, rect in
////            print(rect)
////            return rect
////        }, arguments: [v])
//        self.render.image = a!.apply(extent: v!.extent, roiCallback: { i, rect in
//            print(i,rect)
//            return rect
//        }, image: v!, arguments: [])
    }
}


class ViewController3: UIViewController,VideoViewDelegate {
    func videoPixelCallBack(source: CIImage,bound:CGRect) -> CIImage? {
        return self.gauss.filter(bound: bound, image: source, radius: self.radius)
    }
    func imagePixelCallBack(source: CIImage,bound:CGRect) -> CIImage?{
        source
    }
//
//
    
    let crome = ImageColorMonochrome()
    let pointil:ImageColoredSquares = ImageColoredSquares(type: .HexagonalPixellate)
    let gauss = ImageGaussianBackground()
    let u2 = "https://www.heishenhua.com/video/b1/gamesci_2022PV03.mp4"
    let player = AVPlayer(url: URL(string: "https://www.heishenhua.com/video/b1/gamesci_2021PV02.mp4")!)
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.videoView.video.displayMode = .scaleAspectFill
        self.videoView.delegate = self
        player.play()
        self.videoView.player = player
    }
    @IBOutlet var videoView: VideoHasBackgroundView!
    
    public var radius:CGFloat = 10
    @IBAction func changeRadius(_ sender: UISlider) {
        self.radius = CGFloat(sender.value)
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        
    }
}
public class testp:NSObject,YHPageViewPage,UITableViewDataSource{
    public func viewPageDidLoad() {

    }
    
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
public class aim:UIButton,AMPageViewIndicate{
    public func indicateOffset(offset: CGFloat) {
        self .setTitle("\(offset)", for: .normal)
        self.addTarget(self, action: #selector(handleTouch), for: .touchUpInside)
    }
    
    public var pageView: AMPageView?
    
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
    public var headerHeight:Int  = 128 + 88
    public var indicateHeight:Int = 64
    public var offset:Int = 64 + 88
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

public class page:NSObject,AMPageViewPage,UITableViewDataSource{
    public var pageView: AMPageView?
    
    public func viewPageDidLoad() {

    }
    
    public var view: UIView{
        self.table
    }
    @objc public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    @objc(tableView:cellForRowAtIndexPath:) public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    public var scrollView: UIScrollView {
        self.table
    }
    lazy var table: UITableView = {
        let t = UITableView(frame: .zero, style: .insetGrouped)
//        t.contentInset = UIEdgeInsets(top: 250, left: 0, bottom: 250, right: 0)
        t.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        t.dataSource = self
        return t
    }()
    
}

public class testam:NSObject,AMPageViewDelegate{
    public func numberOfPage() -> NSInteger {
        return 10
    }
    
    public func pageOfIndex(index: Int) -> AMPageViewPage {
        page()
    }
    public var height:Int = 128
    public var indicate:Int = 44
    public func indicateView() -> AMPageViewIndicate {
        let a = aim()
        a.backgroundColor = UIColor.systemOrange
        return a
    }
    
    public func headerView() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.yellow
        return v
    }
    
    public func heightOfHeaderView() -> Int {
        self.height
    }
    
    public func heightOfIndicateView() -> Int {
        return indicate
    }
    public func headerScrollOffset() -> NSInteger {
        return indicate + 88
    }

    public func contentOffsetAt(location: CGPoint) {
        print(location)
    }
}
