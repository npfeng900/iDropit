//
//  DropitBehavior.swift
//  iDropit
//
//  Created by Niu Panfeng on 28/12/2016.
//  Copyright © 2016 NaPaFeng. All rights reserved.
//

import UIKit

class DropitBehavior: UIDynamicBehavior {

    /** Constant */
    struct PathNames {
        static let Attachment = "Attachment"
    }
    
    
    /** UIGravityBehavior */
    let gravity = UIGravityBehavior()
    /** UICollisionBehavior */
    lazy var collider: UICollisionBehavior = {     // 闭包用来设置Behavior的属性
        let lazilyCreatedCollider = UICollisionBehavior()
        lazilyCreatedCollider.translatesReferenceBoundsIntoBoundary = true //reference view的bounds为Behavior的Boundary
        return lazilyCreatedCollider
    }()
    /** UIDynamicItemBehavior */
    lazy var droper: UIDynamicItemBehavior = {
        let lazilyCreatedDroper = UIDynamicItemBehavior()
        lazilyCreatedDroper.allowsRotation = true
        lazilyCreatedDroper.elasticity = 0.75
        return lazilyCreatedDroper
    }()
    /** UIDynamicItemBehavior */
    var attacher: UIAttachmentBehavior? {
        willSet {
            if let attachmentBehaviorToRemove = attacher {
                dynamicAnimator?.removeBehavior(attachmentBehaviorToRemove)
                (dynamicAnimator?.referenceView as? BezierPathsView)!.setPath(nil, named: PathNames.Attachment)
            }
        }
        //在grabDrop中会运行下面的code
        didSet {
            if let attachmentBehaviorToAdd = attacher {
                dynamicAnimator?.addBehavior(attachmentBehaviorToAdd)
                
                //attachedView会随着attachmentBehavior进行刷新
                attacher?.action = { [unowned self] in
                    if let attachedView = self.attacher?.items.first as? UIView {
                        let path = UIBezierPath()
                        path.moveToPoint((self.attacher?.anchorPoint)!)
                        path.addLineToPoint(attachedView.center)
                        (self.dynamicAnimator?.referenceView as? BezierPathsView)!.setPath(path, named: PathNames.Attachment)
                    }
                }
            }
        }
    }
    /** 另外两个
     UISnapBehavior
     UIPushBehavior
     */
    
    
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(droper)
    }
    
    func addAttachment(dropView dropit: UIView, AnchorPoint archor: CGPoint) {
        attacher = UIAttachmentBehavior(item: dropit, attachedToAnchor: archor)
    }
    func setAttachmentAnchorPoint(archor: CGPoint) {
        attacher?.anchorPoint = archor
    }
    func removeAttachment() {
        attacher = nil
    }
    
    func addBarrierPath(path: UIBezierPath, named name: String) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func addDrop(dropView drop: UIView) {
        dynamicAnimator?.referenceView?.addSubview(drop)
        gravity.addItem(drop)
        collider.addItem(drop)
        droper.addItem(drop)
    }
    
    func removeDrop(dropView drop: UIView) {
        gravity.removeItem(drop)
        collider.removeItem(drop)
        droper.removeItem(drop)
        drop.removeFromSuperview()
    }
}
