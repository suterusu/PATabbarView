//
//  PATabbarView+Private.h
//
//  Created by Inba on 2016/03/22.
//  Copyright © 2016年 Inba. All rights reserved.
//

#import "PATabbarPushedView.h"

@interface PATabbarPushedView (Private)

-(void)setNext:(PATabbarPushedView *)next;
-(void)setPrev:(PATabbarPushedView *)prev;
-(void)setState:(PATabbarPushedViewState)state;
-(void)reAddFirstSelfConstraints;
@end
