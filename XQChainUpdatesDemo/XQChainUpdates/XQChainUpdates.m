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

- (nullable instancetype)initWithObj:(NSObject *)obj
                             keyPath:(NSString *)keyPath
                                view:(UIView *)view
                              action:(XQChainActionBlock)action;

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
    
    if (object && keyPath && view && actionBlock) {
        @synchronized (self) {
            NSString *identifier = (NSString *)object.chainIdentifer87;
            if (!identifier) {
                identifier = [NSString stringWithFormat:@"%.0f%.0u", [NSDate timeIntervalSinceReferenceDate], arc4random()];
                object.chainIdentifer87 = identifier;
            }
            
            // save obj paths in the same dictionary
            NSMutableDictionary *objDict = [self.allElements objectForKey:identifier];
            if (!objDict) {
                objDict = [NSMutableDictionary dictionary];
                [self.allElements setObject:objDict forKey:identifier];
            }
            
            ChainElement87 *element = [objDict objectForKey:keyPath];
            if (element) {
                NSString *existChainID = element.eleView.chainIdentifer87;
                // set obj value to other view ,the preview view need do some clear work
                if (element.eleView != view ||
                    ![existChainID isEqualToString:identifier]) {
                    [element.eleObject removeObserverForKeyPath87:element.eleKeyPath];
                }
                element.eleKeyPath = keyPath;
                element.eleAction = actionBlock;
                element.eleView = view;
            } else {
                element = [[ChainElement87 alloc] initWithObj:object keyPath:keyPath view:view action:actionBlock];
            }
            
            element.chainIdentifer87 = identifier;
            view.chainIdentifer87 = identifier;
            
            [object addObserver87:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew];
            [objDict setObject:element forKey:keyPath];
            
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
                        [ele.eleObject removeObserverForKeyPath87:ele.eleKeyPath];
                    }
                    [self.allElements removeObjectForKey:identfier];
                } else {
                    ChainElement87 *ele = [elements objectForKey:keyPath];
                    [ele.eleObject removeObserverForKeyPath87:ele.eleKeyPath];
                    [elements removeObjectForKey:keyPath];
                }
                
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"remove error");
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

- (nullable instancetype)initWithObj:(NSObject *)obj
                             keyPath:(NSString *)keyPath
                                view:(UIView *)view
                              action:(XQChainActionBlock)action {
    if (!obj || !keyPath || !view || !action) {
        return nil;
    }
    
    if (self = [super init]) {
        self.eleObject = obj;
        self.eleKeyPath = keyPath;
        self.eleAction = action;
        self.eleView = view;
    }
    
    return self;
}

- (void)update {
    if (!self.eleView ||
        ![self.eleView.chainIdentifer87 isEqualToString:self.chainIdentifer87]) {
        [self.eleObject removeChainByPath87:nil];
        return;
    }
    
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

@implementation NSObject (XQObserver)

static char observerID87Char;

- (NSString *)observerID87 {
    NSString *identifier = objc_getAssociatedObject(self, &observerID87Char);
    if (!identifier) {
        identifier = [NSString stringWithFormat:@"OB87_%.0f%.0u", [NSDate timeIntervalSinceReferenceDate], arc4random()];
        objc_setAssociatedObject(self, &observerID87Char, identifier, OBJC_ASSOCIATION_COPY);
    }
    
    return identifier;
}

- (void)addObserver87:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options {
    if (!observer || !keyPath) {
        return;
    }
    
    NSString *propertyName = [self getPropertyNameByKeyPath87:keyPath];
    if (!propertyName) {
        return;
    }
    
    NSObject *exitObserver = [[self observerdInfos87] objectForKey:propertyName];
    
    if (exitObserver && exitObserver != observer) {
        NSLog(@"rmb>>%@ removeOb: %@ path:%@", [self observerID87], exitObserver.chainIdentifer87, keyPath);
        [self removeObserver:exitObserver forKeyPath:keyPath];
        exitObserver = nil;
    }
    
    if (!exitObserver) {
        NSLog(@"%@ addOb: %@ path:%@", [self observerID87], observer.chainIdentifer87, keyPath);
        [self addObserver:observer forKeyPath:keyPath options:options context:nil];
        
        [[self observerdInfos87] setObject:observer forKey:propertyName];
    }
}

- (void)removeObserverForKeyPath87:(NSString *)keyPath {
    if (!keyPath) {
        return;
    }
    
    NSString *propertyName = [self getPropertyNameByKeyPath87:keyPath];
    if (!propertyName) {
        return;
    }
    
    NSObject *exitObserver = [[self observerdInfos87] objectForKey:propertyName];
    if (exitObserver) {
        @try {
            [self removeObserver:exitObserver forKeyPath:keyPath];
        } @catch (NSException *exception) {
            // no register
            NSLog(@"remove error ..");
        }
        
        NSLog(@"%@ removeOb: %@ path:%@", [self observerID87], exitObserver.chainIdentifer87, keyPath);
        [[self observerdInfos87] removeObjectForKey:propertyName];
    }
}

- (NSString *)getPropertyNameByKeyPath87:(NSString *)keyPath {
    NSString *obID = [self observerID87];
    if (obID && keyPath) {
        NSString *ID = [obID stringByAppendingString:keyPath];
        return ID;
    }
    
    return nil;
}

static NSMutableDictionary *_observerdInfos87;
- (NSMutableDictionary *)observerdInfos87 {
    if (!_observerdInfos87) {
        _observerdInfos87 = [NSMutableDictionary dictionary];
    }
    
    return _observerdInfos87;
}

@end
