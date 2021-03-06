//
//  UIView+OTWebContentViewActiveKeyboardHack.m
//  OTEditableWebViewDemo
//
//  Created by openthread on 4/10/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "UIView+OTWebContentViewActiveKeyboardHack.h"
#import "WKWebView+OTEditableWebView.h"
#import <objc/runtime.h>

@implementation UIView (OTWebContentViewActiveKeyboardHack)

+ (void)load
{
    //_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:
    NSString *selectorName = [[[[[@"_startAs" stringByAppendingString:@"sisting"]
                                 stringByAppendingString:@"Node:u"]
                                stringByAppendingString:@"serIsInter"]
                               stringByAppendingString:@"acting:blurPrev"]
                              stringByAppendingString:@"iousNode:userObject:"];
    //WKContentView
    NSString *className = [@"WKCo" stringByAppendingString:@"ntentView"];
    Class class = NSClassFromString(className);
    SEL originalSelector = NSSelectorFromString(selectorName);
    SEL newSelector = @selector(otEditingWebViewSwizzStartAssistingNode:userIsInteracting:blurPreviousNode:userObject:);
    [self otEditingWebViewSwizzle:class original:originalSelector new:newSelector];
}

+ (void)otEditingWebViewSwizzle:(Class)c original:(SEL)orig new:(SEL) new
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
    {
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else
    {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

- (void)otEditingWebViewSwizzStartAssistingNode:(void *)node userIsInteracting:(BOOL)isInteracting blurPreviousNode:(BOOL)blurPreviousNode userObject:(id)userObject
{
    UIView *superView = self;
    while (superView)
    {
        superView = superView.superview;
        if ([superView isKindOfClass:[WKWebView class]])
        {
            break;
        }
    }
    
    BOOL canActiveWithoutUserInteraction = NO;
    if ([superView isKindOfClass:[WKWebView class]])
    {
        canActiveWithoutUserInteraction = [((WKWebView *)superView) canActiveKeyboardWithoutUserInteraction];
    }
    
    BOOL userIsInteraction = canActiveWithoutUserInteraction || isInteracting;
    [self otEditingWebViewSwizzStartAssistingNode:node userIsInteracting:userIsInteraction blurPreviousNode:blurPreviousNode userObject:userObject];
}


@end
