//
//  PATabbarView.h
//
//  Created by Inba on 2016/03/05.
//  Copyright (c) 2016年 Inba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PATabbarPushedView.h"

@class PATabbarView;

@protocol PATabbarViewDelegate <NSObject>

@optional
-(void)finishedAdjustAnimationAtForcusedView:(PATabbarPushedView *)forcusedView;
-(void)deletedLastPushedView;

@end

@interface PATabbarView : UIView

#define PATabbarViewRatioOfEmphasisedWidth 0.8
#define PATabbarViewSumOfEmphasisPushedView 4
#define PATabbarViewSumOfDisplayedView 3

#define PATabbarViewDurationForDeleteAnime 0.3
#define PATabbarViewDurationForRepositionAnime 0.5
#define PATabbarViewLatencyUpToRepositionFromDelete 0.7

@property (weak) NSObject<PATabbarViewDelegate> *delegate;

@property (weak,readonly,nonatomic) PATabbarPushedView *head;
@property (weak,readonly,nonatomic) PATabbarPushedView *tail;
@property (weak,readonly,nonatomic) PATabbarPushedView *selectedView;

-(void)addToTailView:(PATabbarPushedView *)view;
-(void)adjustPositionWithAForcusOnView:(PATabbarPushedView *)centerView;
-(void)deleteView:(PATabbarPushedView *)deleteView;
@end