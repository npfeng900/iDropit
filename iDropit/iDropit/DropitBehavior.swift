//
//  DropitBehavior.swift
//  iDropit
//
//  Created by Niu Panfeng on 28/12/2016.
//  Copyright © 2016 NaPaFeng. All rights reserved.
//

import UIKit

class DropitBehavior: UIDynamicBehavior {
    
    let gravity = UIGravityBehavior()
    /// 闭包用来设置Behavior的属性
    lazy var collider: UICollisionBehavior = {
        let lazilyCreatedCollider = UICollisionBehavior()
        lazilyCreatedCollider.translatesReferenceBoundsIntoBoundary = true //reference view的bounds为Behavior的Boundary
        return lazilyCreatedCollider
    }()
    lazy var droper: UIDynamicItemBehavior = {
        let lazilyCreatedDroper = UIDynamicItemBehavior()
        lazilyCreatedDroper.allowsRotation = true
        lazilyCreatedDroper.elasticity = 0.75
        return lazilyCreatedDroper
    }()
    
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(droper)
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
