//
//  PATabbarPushedView.h
//
//  Created by Inba on 2016/03/05.
//  Copyright (c) 2016年 Inba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PATabbarPushedView : UIView

typedef NS_ENUM(NSInteger, PATabbarPushedViewState)
{
    PATabbarPushedViewStatusNotDecide = 0,
    PATabbarPushedViewStatusEmphasis,//These view's width are most wide.
    PATabbarPushedViewStatusDisplayed,//being near left end or right end.　It has a width smaller than EmphasisState
    PATabbarPushedViewStatusNotDisplayed//Not displayed on the PATabbarView.
};
@property (readonly) PATabbarPushedViewState currentState;


/**
 Left side of this view. If not exist It is nil.
 */
@property (weak,readonly) PATabbarPushedView *next;

/**
 Right side of this view. If not exist It is nil.
 */
@property (weak,readonly) PATabbarPushedView *prev;

/**
 When set it YES,This subViews's highlighted also become YES.
 */
@property (nonatomic) BOOL highlighted;

/**
 Called just after changed currentState.
 */
-(void)afterChangeState:(PATabbarPushedViewState)state;

@end
