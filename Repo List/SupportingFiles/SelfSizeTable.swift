//
//  SelfSizedTable.swift
//  Repo List
//
//  Created by Rajiv Puli on 11/08/21.
//


import Foundation
import UIKit

open class SelfSizedTable: UITableView {
    
    override open var contentSize: CGSize {
        didSet { // basically the contentSize gets changed each time a cell is added
            // --> the intrinsicContentSize gets also changed leading to smooth size update
            if oldValue != contentSize {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: contentSize.width, height: contentSize.height)
    }
}

open class SelfSizedCollection: UICollectionView {
    
    var isDynamicSizeRequired = true
      
    open override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
          
          if self.intrinsicContentSize.height > frame.size.height {
            self.invalidateIntrinsicContentSize()
          }
          if isDynamicSizeRequired {
            self.invalidateIntrinsicContentSize()
          }
        }
      }
      
    open override var intrinsicContentSize: CGSize {
        return contentSize
      }
}


