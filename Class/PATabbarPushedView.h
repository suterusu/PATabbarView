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
    PATabbarPushedViewStatusEmphasis,
    PATabbarPushedViewStatusDisplayed,
    PATabbarPushedViewStatusNotDisplayed
};

@property (weak,readonly) PATabbarPushedView *next;
@property (weak,readonly) PATabbarPushedView *prev;
@property (readonly) PATabbarPushedViewState currentState;
@property (nonatomic) BOOL highlighted;
@end
