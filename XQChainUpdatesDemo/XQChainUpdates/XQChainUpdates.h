//
//  XQChainUpdates.h
//
//  Created by qxu on 2016/12/2.
//  Copyright © 2016年 qxu. All rights reserved.
//

@import UIKit;

typedef void(^XQChainActionBlock)(NSObject *obj);

@interface XQChainUpdates : NSObject

/**
 chain object value change to actionBlock
 
 @param object          observed object
 @param keyPath         observed property
 @param view            target view will chain with model
 @param manualUpdate    don't auto trigger update action
 @param actionBlock     when object property value change, actionBlock will be triggered
 */
- (void)chainObject:(NSObject *)object
               path:(NSString *)keyPath
             toView:(UIView *)view
       manualUpdate:(BOOL)manualUpdate
             action:(XQChainActionBlock)actionBlock;


/**
 romove chain   update of object by keyPath
 
 @param object  observed object
 @param keyPath keyPath to remove, if nil, all path will be removed
 */
- (void)removeChainObject:(NSObject *)object path:(NSString *)keyPath;

@end



@interface NSObject (XQChainUpdates)


/**
 chain object path change to action
 
 @param path   keyPath
 @param view   target view will chain with model
 @param action action like update sth
 */
- (void)chainPath87:(NSString *)path view:(UIView *)view action:(XQChainActionBlock)action;

/**
 chain object path change to action
 
 @param path            keyPath
 @param view            target view will chain with model
 @param manualUpdate    don't auto trigger update action
 @param action          action like update sth
 */
- (void)chainPath87:(NSString *)path view:(UIView *)view manualUpdate:(BOOL)manualUpdate action:(XQChainActionBlock)action;


/**
 remove chain path

 @param keyPath keyPath
 */
- (void)removeChainByPath87:(NSString *)keyPath;

@end
