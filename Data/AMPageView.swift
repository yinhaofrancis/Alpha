
import UIKit


public class TestView:UIView{
    @IBOutlet weak var cons:NSLayoutConstraint!
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.transform = CGAffineTransform(translationX: 0, y: 50)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            self.cons.constant = 100;
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.transform = CGAffineTransform.identity
                self.superview?.layoutIfNeeded()
            } completion: { b in
                
            }
        }
    }
}
