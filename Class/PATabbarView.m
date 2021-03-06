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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefParams];
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setDefParams];
    _firstConstrainsArray = [NSArray arrayWithArray:self.constraints];
    if (self.isEnableSwipe == YES) {
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        
        UISwipeGestureRecognizer *swipeL = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft:)];
        swipeL.direction = UISwipeGestureRecognizerDirectionLeft;
        
        UISwipeGestureRecognizer *swipeR = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
        swipeR.direction = UISwipeGestureRecognizerDirectionRight;
        
        [self addGestureRecognizer:pan];
    }
}

-(void)swipeRight{
    PATabbarPushedView *center = nil;
    for (PATabbarPushedView *pushedView = self.head; pushedView; pushedView = pushedView.next) {
        if (pushedView.currentState == PATabbarPushedViewStatusDisplayed) {
            center = pushedView;
        }
        if (pushedView.currentState == PATabbarPushedViewStatusEmphasis) {
            break;
        }
        
    }
    
    if (center) {
        [self adjustPositionWithAForcusOnView:center];
    }
}


-(void)swipeLeft{
    PATabbarPushedView *center = nil;
    for (PATabbarPushedView *pushedView = self.tail; pushedView; pushedView = pushedView.prev) {
        if (pushedView.currentState == PATabbarPushedViewStatusDisplayed) {
            center = pushedView;
        }
        if (pushedView.currentState == PATabbarPushedViewStatusEmphasis) {
            break;
        }
    }
    
    if (center) {
        [self adjustPositionWithAForcusOnView:center];
    }
}


-(void)pan:(UIPanGestureRecognizer *)pan{
    CGPoint touchPoint = [pan translationInView:pan.view];
    if (touchPoint.x > 60) {
        [self swipeRight];
        [pan setTranslation:CGPointZero inView:pan.view];
    }else if(touchPoint.x < -60){
        [self swipeLeft];
        [pan setTranslation:CGPointZero inView:pan.view];
    }
}





-(void)setDefParams{
    _ratioOfEmphasisedViewWidth = 0.8;
    _sumOfDisplayedView = 4;
    _sumOfEmphasisPushedView = 3;
    _durationForDeleteAnime = 0.3;
    _durationForRepositionAnime = 0.5;
    _latencyUpToRepositionFromDelete = 0.7;
    _lengthBetweenPushedViews = 1;
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
        [UIView animateWithDuration:_durationForDeleteAnime animations:^{
            if (nextOfDeleteView) {
                [NSLayoutConstraint deactivateConstraints:nextOfDeleteView.constraints];
                [nextOfDeleteView reAddFirstSelfConstraints];
                
                [[NSLayoutConstraint constraintWithItem:nextOfDeleteView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:deleteView.frame.size.width] setActive:YES];//Width
                [[NSLayoutConstraint constraintWithItem:nextOfDeleteView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:deleteView.frame.size.height] setActive:YES];//Height
                [nextOfDeleteView setState:PATabbarPushedViewStatusEmphasis];
            }
            
            if ((previousOfDeleteView == nil)&&nextOfDeleteView) {//nextSelectedView is head |-(0)-nextSelectedView
                [[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:nextOfDeleteView attribute:NSLayoutAttributeLeft multiplier:1 constant:_lengthBetweenPushedViews] setActive:YES];
            }else if (nextOfDeleteView&&previousOfDeleteView){//previous-(0)-next
                [[NSLayoutConstraint constraintWithItem:previousOfDeleteView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:nextOfDeleteView attribute:NSLayoutAttributeLeft multiplier:1 constant:_lengthBetweenPushedViews] setActive:YES];
            }
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (nextSelectedView) {
                [NSTimer scheduledTimerWithTimeInterval:_latencyUpToRepositionFromDelete target:self selector:@selector(adjustmentIfInInterface:) userInfo:@{PATabbarViewKeyNextAdjustmentTarget:nextSelectedView} repeats:NO];

            }
        }];
    }else{//delete the last one
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
    [NSLayoutConstraint deactivateConstraints:self.constraints];
    for (PATabbarPushedView *pushedView = self.head; pushedView; pushedView = pushedView.next) {
        [NSLayoutConstraint deactivateConstraints:pushedView.constraints];
        [pushedView reAddFirstSelfConstraints
         ];
    }
    
    //Resetup Constraints
    [NSLayoutConstraint activateConstraints:_firstConstrainsArray];
    
    [[NSLayoutConstraint constraintWithItem:_head attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:_head attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]setActive:YES];
    
    for (PATabbarPushedView *pushedView = self.head; pushedView; pushedView = pushedView.next) {
        [[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:pushedView attribute:NSLayoutAttributeTop multiplier:1 constant:0]setActive:YES];
        [[NSLayoutConstraint constraintWithItem:pushedView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.frame.size.height] setActive:YES];
    }
    
    NSDictionary *dicSeparatedStatus = [self setStatesForPushedViewsInListOnTheBasisOfView:centerView];
    CGFloat emphasisViewWidth;
    CGFloat displayViewWidth;
    NSArray *emphasisDisplayedViews = dicSeparatedStatus[PATabbarViewKeyEmphasis];
    NSArray *displayedViews = dicSeparatedStatus[PATabbarViewKeyDisplayed];
    NSArray *notDisplayedViews = dicSeparatedStatus[PATabbarViewKeyNotDisplayedViews];
    CGFloat sumOfSpaceLength = (emphasisDisplayedViews.count+displayedViews.count - 1)*_lengthBetweenPushedViews;
    if (displayedViews.count == 0) {
        emphasisViewWidth = (self.frame.size.width-sumOfSpaceLength)/emphasisDisplayedViews.count;
        displayViewWidth = 0;
    }else{
        emphasisViewWidth = (self.frame.size.width-sumOfSpaceLength)*_ratioOfEmphasisedViewWidth/emphasisDisplayedViews.count;
        displayViewWidth = ((self.frame.size.width-sumOfSpaceLength) - (self.frame.size.width-sumOfSpaceLength)*_ratioOfEmphasisedViewWidth)/displayedViews.count;
    }

    for (PATabbarPushedView *pushedView = self.head; pushedView; pushedView = pushedView.next) {
        float spaceLength = 0;//only exist between displayed and emphasis pushedViews
            
        if ([emphasisDisplayedViews containsObject:pushedView]) {
            [[NSLayoutConstraint constraintWithItem:pushedView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:emphasisViewWidth] setActive:YES];
            spaceLength = _lengthBetweenPushedViews;
        }else if ([displayedViews containsObject:pushedView]){
            [[NSLayoutConstraint constraintWithItem:pushedView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:displayViewWidth] setActive:YES];
            spaceLength = _lengthBetweenPushedViews;
        }else{
            [[NSLayoutConstraint constraintWithItem:pushedView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0] setActive:YES];
        }
        
        if (pushedView.next) {
            if ((spaceLength >0) && ([notDisplayedViews containsObject:pushedView.next]) ) {
                spaceLength = 0;
            }
            [[NSLayoutConstraint constraintWithItem:pushedView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:pushedView.next attribute:NSLayoutAttributeLeft multiplier:1 constant:-spaceLength] setActive:YES];
        }
    }
    
    [UIView animateWithDuration:_durationForRepositionAnime animations:^{
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
        if (emphasisDisplayedViews.count >=_sumOfEmphasisPushedView) {
            currentAddedArray = displayedViews;
            currentSettingState = PATabbarPushedViewStatusDisplayed;
        }
        if (displayedViews.count >= _sumOfDisplayedView) {
            currentAddedArray = notDisplayedViews;
            currentSettingState = PATabbarPushedViewStatusNotDisplayed;
        }
        
        if (prev) {
            [prev setState:currentSettingState];
            [currentAddedArray addObject:prev];
            prev = prev.prev;
        }
        if (emphasisDisplayedViews.count >=_sumOfEmphasisPushedView) {
            currentAddedArray = displayedViews;
            currentSettingState = PATabbarPushedViewStatusDisplayed;
        }
        if (displayedViews.count >= _sumOfDisplayedView) {
            currentAddedArray = notDisplayedViews;
            currentSettingState = PATabbarPushedViewStatusNotDisplayed;
        }
        
        if ((prev == nil)&&(next == nil)) {
            break;
        }
    }
    
    return @{PATabbarViewKeyEmphasis:[NSArray arrayWithArray:emphasisDisplayedViews],PATabbarViewKeyDisplayed:[NSArray arrayWithArray:displayedViews],PATabbarViewKeyNotDisplayedViews:[NSArray arrayWithArray:notDisplayedViews]};
}

#pragma mark -Private

-(PATabbarPushedView *)tail{
    for (PATabbarPushedView *pushedView = self.head; pushedView; pushedView = pushedView.next) {
        if (pushedView.next == nil) {
            return pushedView;
        }
    }
    return nil;
}

-(void)dealloc{
    _firstConstrainsArray = nil;
}

#pragma mark - Class method

+(void)deleteAllConstraintsRelatedView:(UIView *)relatedView FromView:(UIView *)from{
    NSMutableArray *newConstraints = [NSMutableArray array];
    
    [from.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj.firstItem isEqual:relatedView]&&![obj.secondItem isEqual:relatedView]) {
            [newConstraints addObject:obj];
        }
    }];
    
    [NSLayoutConstraint deactivateConstraints:from.constraints];
    [NSLayoutConstraint activateConstraints:[NSArray arrayWithArray:newConstraints]];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
