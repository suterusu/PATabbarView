//
//  PATabbarPushedView.m
//
//  Created by Inba on 2016/03/05.
//  Copyright (c) 2016年 Inba. All rights reserved.
//

#import "PATabbarPushedView.h"
#import "PATabbarPushedView+Private.h"

@implementation PATabbarPushedView{
    NSArray *_constraints;
    BOOL _highlighted;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    _constraints = self.constraints;
}

-(instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         self.translatesAutoresizingMaskIntoConstraints = NO;
        _constraints = self.constraints;
    }
    return self;
}

-(void)setHighlighted:(BOOL)highlighted{
    _highlighted = highlighted;
    [self.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(setHighlighted:)]) {
            [obj setValue:@(highlighted) forKey:@"highlighted"];
        };
    }];
}

-(void)afterChangeState:(PATabbarPushedViewState)state{
    //abstract
}

-(void)addConstraint:(NSLayoutConstraint *)constraint{
    [super addConstraint:constraint];
    if (self.currentState == PATabbarPushedViewStatusNotDecide) {
        _constraints = self.constraints;
    }
}

-(void)addConstraints:(NSArray<__kindof NSLayoutConstraint *> *)constraints{
    [super addConstraints:constraints];
    if (self.currentState == PATabbarPushedViewStatusNotDecide) {
        _constraints = self.constraints;
    }
}

-(void)dealloc{
    _constraints = nil;
}

@end

@implementation PATabbarPushedView (Private)

-(void)reAddFirstSelfConstraints{
    [self addConstraints:_constraints];
}

-(void)setNext:(PATabbarPushedView *)next{
    _next = next;
    if (next) {
        next->_prev = self;
    }
}

-(void)setPrev:(PATabbarPushedView *)prev{
    _prev = prev;
    if (prev) {
        prev->_next = self;
    }
}

-(void)setState:(PATabbarPushedViewState)state{
    [self afterChangeState:state];
    _currentState = state;
}



@end
