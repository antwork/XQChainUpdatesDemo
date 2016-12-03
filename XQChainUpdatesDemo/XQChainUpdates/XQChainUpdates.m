//
//  XQChainUpdates.m
//
//  Created by qxu on 2016/12/2.
//  Copyright © 2016年 qxu. All rights reserved.
//

@import UIKit;
#import "XQChainUpdates.h"
#import <objc/runtime.h>


@class XQChainUpdates;

@interface NSObject (ChainIdentifier87)
@property (nonatomic, strong) NSString *chainIdentifer87;
@end


@interface ChainElement87 : NSObject

@property (nonatomic, strong) NSObject *eleObject;

@property (nonatomic, copy) NSString *eleKeyPath;

@property (nonatomic, copy) XQChainActionBlock eleAction;

@property (nonatomic, weak) UIView *eleView;

@property (nonatomic, weak) NSMutableDictionary *allElements;

- (instancetype)initWithObj:(NSObject *)obj keyPath:(NSString *)keyPath action:(XQChainActionBlock)action;

- (void)update;

@end


@interface XQChainUpdates ()

@property (nonatomic, strong) NSMutableDictionary *allElements;

@end



@implementation XQChainUpdates

#pragma mark - APIs

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
             action:(XQChainActionBlock)actionBlock {
    
    if (object && keyPath && actionBlock) {
        
        NSString *identifier = (NSString *)object.chainIdentifer87;
        if (!identifier) {
            identifier = [NSString stringWithFormat:@"%.0f%.0u", [NSDate timeIntervalSinceReferenceDate], arc4random()];
            object.chainIdentifer87 = identifier;
        }
        
        view.chainIdentifer87 = identifier;
        
        ChainElement87 *element = [[ChainElement87 alloc] initWithObj:object keyPath:keyPath action:actionBlock];
        element.chainIdentifer87 = identifier;
        element.eleView = view;
        element.allElements = self.allElements;
        
        @synchronized (self) {
            // save obj paths in the same dictionary
            NSMutableDictionary *objDict = [self.allElements objectForKey:identifier];
            if (!objDict) {
                objDict = [NSMutableDictionary dictionary];
                [self.allElements setObject:objDict forKey:identifier];
            }
            
            [objDict setObject:element forKey:keyPath];
            
            // fobid regist more than once
            @try {
                [object removeObserver:self forKeyPath:keyPath];
            } @catch (NSException *exception) {
                // no register
            }
            
            [object addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
            
            if (!manualUpdate) {
                [element update];
            }
        }
    }
}


/**
 romove chain update of object by keyPath

 @param object  observed object
 @param keyPath keyPath to remove, if nil, all path will be removed
 */
- (void)removeChainObject:(NSObject *)object path:(NSString *)keyPath {
    NSString *identfier = (NSString *)[object chainIdentifer87];
    if (!identfier) {
        return;
    }
    
    @try {
        @synchronized (self) {
            NSMutableDictionary *elements = [self.allElements objectForKey:identfier];
            if (elements) {
                if (!keyPath) {
                    for (ChainElement87 *ele in elements.allValues) {
                        [ele.eleObject removeObserver:self forKeyPath:ele.eleKeyPath];
                    }
                    [self.allElements removeObjectForKey:identfier];
                } else {
                    ChainElement87 *ele = [elements objectForKey:keyPath];
                    [ele.eleObject removeObserver:self forKeyPath:ele.eleKeyPath];
                    [elements removeObjectForKey:keyPath];
                }
                
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"error");
    } @finally {
        
    }
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSString *identifier = (NSString *)[object chainIdentifer87];
    if (!identifier) {
        return;
    }
    
    ChainElement87 *element = [[self.allElements objectForKey:identifier] objectForKey:keyPath];
    if (element) {
        [element update];
    }
}

#pragma mark Getter

- (NSMutableDictionary *)allElements {
    if (!_allElements) {
        _allElements = [NSMutableDictionary dictionary];
    }
    return _allElements;
}

@end

#pragma mark - Handle unique id for object

@implementation NSObject (ChainIdentifier87)

static char chainIdentifer87Char;

- (void)setChainIdentifer87:(NSString *)chainIdentifer87 {
    objc_setAssociatedObject(self, &chainIdentifer87Char, chainIdentifer87, OBJC_ASSOCIATION_COPY);
}

- (NSMutableArray *)chainIdentifer87 {
    return objc_getAssociatedObject(self, &chainIdentifer87Char);
}

@end


#pragma mark - Handle detail of KVCElement

@implementation ChainElement87

- (instancetype)initWithObj:(NSObject *)obj keyPath:(NSString *)keyPath action:(XQChainActionBlock)action {
    if (self = [super init]) {
        self.eleObject = obj;
        self.eleKeyPath = keyPath;
        self.eleAction = action;
    }
    
    return self;
}

- (void)update {
    // call block in main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.eleView && self.eleObject && self.eleAction &&
            [self.eleView.chainIdentifer87 isEqualToString:self.eleObject.chainIdentifer87]) {
            self.eleAction(self.eleObject);
            
            [self checkForDealloc];
        }
    });
}

- (void)checkForDealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkForDealloc) object:nil];
    if (!self.eleView) {
        NSLog(@"keychain removed:%@ %@", self.chainIdentifer87, self.eleKeyPath);
        [self.eleObject removeChainByPath87:nil];
    } else {
        [self performSelector:@selector(checkForDealloc) withObject:nil afterDelay:5.0];
    }
}

- (void)dealloc {
    NSLog(@"keychain dealloc:%@ %@", self.chainIdentifer87, self.eleKeyPath);
}


@end

#pragma mark - NSObject+XQChainUpdates

@implementation NSObject (XQChainUpdates)

/**
 chain object path change to action
 
 @param path   keyPath
 @param view   target view will chain with model
 @param action action like update sth
 */
- (void)chainPath87:(NSString *)path view:(UIView *)view action:(XQChainActionBlock)action {
    [[self relatedUpdateHelper] chainObject:self path:path toView:view manualUpdate:false action:action];
}

/**
 chain object path change to action
 
 @param path            keyPath
 @param view            target view will chain with model
 @param manualUpdate    don't auto trigger update action
 @param action          action like update sth
 */
- (void)chainPath87:(NSString *)path view:(UIView *)view manualUpdate:(BOOL)manualUpdate action:(XQChainActionBlock)action {
    [[self relatedUpdateHelper] chainObject:self path:path toView:view manualUpdate:manualUpdate action:action];
}



/**
 remove chain   path
 
 @param keyPath keyPath
 */

- (void)removeChainByPath87:(NSString *)keyPath {
    [[self relatedUpdateHelper] removeChainObject:self path:keyPath];
}

static XQChainUpdates *_relateUpdate;

- (XQChainUpdates *)relatedUpdateHelper {
    if (_relateUpdate == nil) {
        _relateUpdate = [[XQChainUpdates alloc] init];
    }
    return _relateUpdate;
}

@end
