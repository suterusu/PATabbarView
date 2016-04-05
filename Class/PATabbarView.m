//
//  PATabbarView.m
//
//  Created by Inba on 2016/03/05.
//  Copyright (c) 2016年 Inba. All rights reserved.
//

#import "PATabbarView.h"
#import "PATabbarPushedView+Private.h"
#import "PATabbarPushedView.h"

#define PATabbarViewKeyEmphasis @"Emphasis"
#define PATabbarViewKeyDisplayed @"Displayed"
#define PATabbarViewKeyNotDisplayedViews @"NotDisplayed"
#define PATabbarViewKeyNextAdjustmentTarget @"NextAdjustment"

@implementation PATabbarView{
    NSArray *_firstConstrainsArray;
}


-(void)addToTailView:(PATabbarPushedView *)view{
    CGFloat firstWidth = view.frame.size.width?:50;
    
    view.frame = CGRectMake(self.frame.size.width+firstWidth, 0, firstWidth, self.frame.size.height);
    view.translatesAutoresizingMaskIntoConstraints = YES;
    [self addSubview:view];
    [view setNeedsLayout];
    [view layoutIfNeeded];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (self.head == nil) {
        _head = view;
    }else{
        [self.tail setNext:view];
    }
    [self adjustPositionWithAForcusOnView:view];
}

-(void)deleteView:(PATabbarPushedView *)deleteView{
    PATabbarPushedView *nextOfDeleteView = deleteView.next;
    PATabbarPushedView *previousOfDeleteView = deleteView.prev;
    PATabbarPushedView *nextSelectedView = nextOfDeleteView ? nextOfDeleteView:previousOfDeleteView;
    
    if (previousOfDeleteView == nil) {//deleteView is Head
        _head = nextOfDeleteView;
    }
    
    //connext next and prev
    if (previousOfDeleteView) {
        [previousOfDeleteView setNext:nextOfDeleteView];
    }
    if (nextOfDeleteView) {
        [nextOfDeleteView setPrev:previousOfDeleteView];
    }
    
    
    [PATabbarView deleteAllConstraintsRelatedView:deleteView FromView:self];
    [deleteView removeFromSuperview];
    
    if (nextSelectedView) {
        deleteView.hidden = YES;
        [UIView animateWithDuration:PATabbarViewDurationForDeleteAnime animations:^{
            if (nextOfDeleteView) {
                [nextOfDeleteView removeConstraints:nextOfDeleteView.constraints];
                [nextOfDeleteView reAddFirstSelfConstraints];
                
                [nextOfDeleteView addConstraint:[NSLayoutConstraint constraintWithItem:nextOfDeleteView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:deleteView.frame.size.width]];//Width
                [nextOfDeleteView addConstraint:[NSLayoutConstraint constraintWithItem:nextOfDeleteView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:deleteView.frame.size.height]];//Height
                [nextOfDeleteView setState:PATabbarPushedViewStatusEmphasis];
            }
            
            if ((previousOfDeleteView == nil)&&nextOfDeleteView) {//nextSelectedView is head |-(0)-nextSelectedView
                [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:nextOfDeleteView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
            }else if (nextOfDeleteView&&previousOfDeleteView){//previous-(0)-next
                [self addConstraint:[NSLayoutConstraint constraintWithItem:previousOfDeleteView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:nextOfDeleteView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
            }
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (nextSelectedView) {
                [NSTimer scheduledTimerWithTimeInterval:PATabbarViewLatencyUpToRepositionFromDelete target:self selector:@selector(adjustmentIfInInterface:) userInfo:@{PATabbarViewKeyNextAdjustmentTarget:nextSelectedView} repeats:NO];

            }
        }];
    }else{//zero
        if ([self.delegate respondsToSelector:@selector(deletedLastPushedView)]) {
            [self.delegate deletedLastPushedView];
        }
    }
}

-(void)adjustmentIfInInterface:(NSTimer *)timer{
    PATabbarPushedView *view = timer.userInfo[PATabbarViewKeyNextAdjustmentTarget];
    if (view.superview) {
        [self adjustPositionWithAForcusOnView:view];
    }
}

-(void)adjustPositionWithAForcusOnView:(PATabbarPushedView *)centerView{
    //Delete All Constraints
    [self removeConstraints:self.constraints];
    for (PATabbarPushedView *pushedView = self.head; pushedView; pushedView = pushedView.next) {
        [pushedView removeConstraints:pushedView.constraints];
        [pushedView reAddFirstSelfConstraints
         ];
    }
    
    //Resetup Constraints
    [self addConstraints:_firstConstrainsArray];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_head attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_head attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    for (PATabbarPushedView *pushedView = self.head; pushedView; pushedView = pushedView.next) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:pushedView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [pushedView addConstraint:[NSLayoutConstraint constraintWithItem:pushedView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.frame.size.height]];
    }
    
    NSDictionary *dicSeparatedStatus = [self setStatesForPushedViewsInListOnTheBasisOfView:centerView];
    CGFloat emphasisViewWidth;
    CGFloat displayViewWidth;
    NSArray *emphasisDisplayedViews = dicSeparatedStatus[PATabbarViewKeyEmphasis];
    NSArray *displayedViews = dicSeparatedStatus[PATabbarViewKeyDisplayed];
    if (displayedViews.count == 0) {
        emphasisViewWidth = self.frame.size.width/emphasisDisplayedViews.count;
        displayViewWidth = 0;
    }else{
        emphasisViewWidth = self.frame.size.width*PATabbarViewRatioOfEmphasisedWidth/emphasisDisplayedViews.count;
        displayViewWidth = (self.frame.size.width - self.frame.size.width*PATabbarViewRatioOfEmphasisedWidth)/displayedViews.count;
    }

    for (PATabbarPushedView *pushedView = self.head; pushedView; pushedView = pushedView.next) {
        if (pushedView.next) {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:pushedView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:pushedView.next attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        }
            
        if ([emphasisDisplayedViews containsObject:pushedView]) {
                [pushedView addConstraint:[NSLayoutConstraint constraintWithItem:pushedView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:emphasisViewWidth]];
        }else if ([displayedViews containsObject:pushedView]){
                [pushedView addConstraint:[NSLayoutConstraint constraintWithItem:pushedView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:displayViewWidth]];
        }else{
                [pushedView addConstraint:[NSLayoutConstraint constraintWithItem:pushedView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0]];
        }
    }
    
    [UIView animateWithDuration:PATabbarViewDurationForRepositionAnime animations:^{
        [self layoutIfNeeded];
    }completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(finishedAdjustAnimationAtForcusedView:)]) {
            [self.delegate finishedAdjustAnimationAtForcusedView:centerView];
        }
    }];
}


/**
 @return ResultDictionary
 **/
-(NSDictionary *)setStatesForPushedViewsInListOnTheBasisOfView:(PATabbarPushedView *)center{
    PATabbarPushedViewState currentSettingState = PATabbarPushedViewStatusEmphasis;
    
    NSMutableArray *emphasisDisplayedViews = [NSMutableArray array];
    NSMutableArray *displayedViews = [NSMutableArray array];
    NSMutableArray *notDisplayedViews = [NSMutableArray array];
    
    NSMutableArray *currentAddedArray = emphasisDisplayedViews;
    
    [center setState:currentSettingState];
    [emphasisDisplayedViews addObject:center];
    
    PATabbarPushedView *next = center.next;
    PATabbarPushedView *prev = center.prev;
    
    while (YES) {
        if (next) {
            [next setState:currentSettingState];
            [currentAddedArray addObject:next];
            next = next.next;
        }
        if (emphasisDisplayedViews.count >=PATabbarViewSumOfEmphasisPushedView) {
            currentAddedArray = displayedViews;
            currentSettingState = PATabbarPushedViewStatusDisplayed;
        }
        if (displayedViews.count >= PATabbarViewSumOfDisplayedView) {
            currentAddedArray = notDisplayedViews;
            currentSettingState = PATabbarPushedViewStatusNotDisplayed;
        }
        
        if (prev) {
            [prev setState:currentSettingState];
            [currentAddedArray addObject:prev];
            prev = prev.prev;
        }
        if (emphasisDisplayedViews.count >=PATabbarViewSumOfEmphasisPushedView) {
            currentAddedArray = displayedViews;
            currentSettingState = PATabbarPushedViewStatusDisplayed;
        }
        if (displayedViews.count >= PATabbarViewSumOfDisplayedView) {
            currentAddedArray = notDisplayedViews;
            currentSettingState = PATabbarPushedViewStatusNotDisplayed;
        }
        
        if ((prev == nil)&&(next == nil)) {
            break;
        }
    }
    
    return @{PATabbarViewKeyEmphasis:[NSArray arrayWithArray:emphasisDisplayedViews],PATabbarViewKeyDisplayed:[NSArray arrayWithArray:displayedViews],PATabbarViewKeyNotDisplayedViews:[NSArray arrayWithArray:notDisplayedViews]};
}


//Private
-(PATabbarPushedView *)tail{
    for (PATabbarPushedView *pushedView = self.head; pushedView; pushedView = pushedView.next) {
        if (pushedView.next == nil) {
            return pushedView;
        }
    }
    return nil;
}

-(void)awakeFromNib{
    _firstConstrainsArray = [NSArray arrayWithArray:self.constraints];
}

-(void)dealloc{
    _firstConstrainsArray = nil;
}

+(void)deleteAllConstraintsRelatedView:(UIView *)relatedView FromView:(UIView *)from{
    NSMutableArray *newConstraints = [NSMutableArray array];
    
    [from.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj.firstItem isEqual:relatedView]&&![obj.secondItem isEqual:relatedView]) {
            [newConstraints addObject:obj];
        }
    }];
    
    [from removeConstraints:from.constraints];
    [from addConstraints:[NSArray arrayWithArray:newConstraints]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
