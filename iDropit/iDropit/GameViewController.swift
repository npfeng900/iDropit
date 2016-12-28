//
//  ViewController.swift
//  iDropit
//
//  Created by Niu Panfeng on 27/12/2016.
//  Copyright © 2016 NaPaFeng. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UIDynamicAnimatorDelegate {
    
    // MARK: - Property
    /// drop的显示父视图
    @IBOutlet weak var gameView: UIView!
    /// 每行的drop数目
    var dropsPerRow = 10
    /// drop的尺寸
    var dropSize: CGSize {
        let size = gameView.bounds.width / CGFloat(dropsPerRow)
        return CGSize(width: size, height: size)
    }
    /// UIDynamicAnimator
    lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedDynamicAnimator.delegate = self
        return lazilyCreatedDynamicAnimator
    }()
    /// Behavior
    let dropitBehavior = DropitBehavior()
    
    
    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(dropitBehavior)
    }
    
    // MARK: - UIDynamicAnimatorDelegate
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        removeBottomCompletedRow()
    }
    /** 删除堆满drop的最下面的一行 */
    private func removeBottomCompletedRow() {
        var dropsToRemove = [UIView]()
        var dropFrame = CGRect(x: 0, y: gameView.frame.maxY, width: dropSize.width, height: dropSize.height)
        
        repeat {
            //将要遍历行的起始位置
            dropFrame.origin.x = 0
            dropFrame.origin.y -= dropSize.height
            
            var dropsFound = [UIView]()
            var rowIsCompleted = true
            
            //开始遍历一行，并将找到hitView的添加到dropsFound
            for _ in 0 ..< dropsPerRow {
                if let hitView = gameView.hitTest(CGPoint(x: dropFrame.midX, y: dropFrame.midY), withEvent: nil)
                {
                    if hitView.superview == gameView {
                        dropsFound.append(hitView)
                    }
                    else {
                        rowIsCompleted = false
                    }
                }
                //设置该行当前遍历的下一个
                dropFrame.origin.x += dropSize.width
            }
            
            //找到满足条件的一行，将会发生dropsToRemove.count != 0
            if rowIsCompleted {
                dropsToRemove += dropsFound
            }
            
        }
            // 找到一行，即 dropsToRemove.count != 0 ，不再进行循环
            while dropsToRemove.count == 0 && dropFrame.origin.y > 0
        
        // 删除找到的dropsToRemove
        for drop in dropsToRemove {
            dropitBehavior.removeDrop(dropView: drop)
        }
    }

    // MARK: - Self Define
    /** tap动作 */
    @IBAction func drop(sender: UITapGestureRecognizer) {
        drop()
    }
    private func drop() {
        var frame = CGRect(origin: CGPointZero, size: dropSize)
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
        
        let dropView = UIView(frame: frame)
        dropView.backgroundColor = UIColor.random
        
        dropitBehavior.addDrop(dropView: dropView)
        
    }
    
}
// MARK: - Extension of CGFloat and UIColor
/** CGFloat的静态方法扩展 */
private extension CGFloat {
    static func random(max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}
/** UIColor的类型属性扩展 */
private extension UIColor {
    class var random: UIColor {
        switch arc4random() % 7
        {
        case 0: return UIColor.greenColor()
        case 1: return UIColor.redColor()
        case 2: return UIColor.blueColor()
        case 3: return UIColor.purpleColor()
        case 4: return UIColor.orangeColor()
        case 5: return UIColor.yellowColor()
        case 6: return UIColor.brownColor()
        default: return UIColor.blueColor()
        }
    }
}

