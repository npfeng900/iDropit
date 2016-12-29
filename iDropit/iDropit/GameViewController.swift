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
    /** drop的显示父视图 */
    @IBOutlet weak var gameView: BezierPathsView! {
        didSet {
            gameView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "grabDrop:"))
        }
    }
    
    /** 每行的drop数目 */
    var dropitsPerRow = 10
    /** drop的尺寸 */
    var dropitSize: CGSize {
        let size = gameView.bounds.width / CGFloat(dropitsPerRow)
        return CGSize(width: size, height: size)
    }
    /** 最后一个drop */
    var lastDropit: UIView?
    
    /** UIDynamicAnimator,闭包用来生成lazy的UIDynamicAnimator，gameView在init时还不存在  */
    lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedDynamicAnimator.delegate = self
        return lazilyCreatedDynamicAnimator
    }()
    /** Behavior */
    let dropitBehavior = DropitBehavior()
    var attachmentBehavior: UIAttachmentBehavior? {
        willSet {
            if let attachmentBehaviorToRemove = attachmentBehavior {
                animator.removeBehavior(attachmentBehaviorToRemove)
                gameView.setPath(nil, named: PathNames.Attachment)
            }
        }
        //在grabDrop中会运行下面的code
        didSet {
            if let attachmentBehaviorToAdd = attachmentBehavior {
                animator.addBehavior(attachmentBehaviorToAdd)
                
                //attachedView会随着attachmentBehavior进行刷新
                attachmentBehavior?.action = { [unowned self] in
                    if let attachedView = self.attachmentBehavior?.items.first as? UIView {
                        let path = UIBezierPath()
                        path.moveToPoint((self.attachmentBehavior?.anchorPoint)!)
                        path.addLineToPoint(attachedView.center)
                        self.gameView.setPath(path, named: PathNames.Attachment)
                    }
                }
            }
        }
    }
    
    /** Constant */
    struct PathNames {
        static let MiddleBarrier = "Middle Barrier"
        static let Attachment = "Attachment"
    }
    
    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator.addBehavior(dropitBehavior)
    }
    /** LayoutSubviews：增加障碍 */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let barrierSize = dropitSize
        let barrierOrigin = CGPoint(x: gameView.bounds.midX - barrierSize.width/2, y: gameView.bounds.midY - barrierSize.height/2)
        let path = UIBezierPath(ovalInRect: CGRect(origin: barrierOrigin, size: barrierSize))
       
        dropitBehavior.addBarrierPath(path, named: PathNames.MiddleBarrier)
        gameView.setPath(path, named: PathNames.MiddleBarrier)
    }
    
    // MARK: - UIDynamicAnimatorDelegate
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        removeBottomCompletedRow()
    }
    /** 删除堆满drop的最下面的一行 */
    private func removeBottomCompletedRow() {
        var dropsToRemove = [UIView]()
        var dropFrame = CGRect(x: 0, y: gameView.frame.maxY, width: dropitSize.width, height: dropitSize.height)
        
        repeat {
            //将要遍历行的起始位置
            dropFrame.origin.x = 0
            dropFrame.origin.y -= dropitSize.height
            
            var dropsFound = [UIView]()
            var rowIsCompleted = true
            
            //开始遍历一行，并将找到hitView的添加到dropsFound
            for _ in 0 ..< dropitsPerRow {
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
                dropFrame.origin.x += dropitSize.width
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

    // MARK: - UIGestureRecognizer
    /** tap动作 */
    @IBAction func drop(sender: UITapGestureRecognizer) {
        drop()
    }
    private func drop() {
        var frame = CGRect(origin: CGPointZero, size: dropitSize)
        frame.origin.x = CGFloat.random(dropitsPerRow) * dropitSize.width
        
        let dropitView = UIView(frame: frame)
        dropitView.backgroundColor = UIColor.random
        
        lastDropit = dropitView
        dropitBehavior.addDrop(dropView: dropitView)
        
    }
    /** pan动作 */
    func grabDrop(gesture: UIPanGestureRecognizer) {
        let gesturePoint = gesture.locationInView(gameView)
        switch gesture.state
        {
        case .Began:
            if let viewToAttachTo = lastDropit {
                attachmentBehavior = UIAttachmentBehavior(item: viewToAttachTo, attachedToAnchor: gesturePoint)
                lastDropit = nil //不能反复抓住同一个dropit
            }
        case .Changed:
            attachmentBehavior?.anchorPoint = gesturePoint
        case .Ended:
            attachmentBehavior = nil
        default:
            break
        }
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

