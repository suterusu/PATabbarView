//
//  ExampleSubPushedView2.h
//  PATabbarView
//
//  Created by Inba on 2016/06/14.
//  Copyright © 2016年 Inba. All rights reserved.
//

#import "PATabbarPushedView.h"

@class ExampleSubPushedView2;

@protocol ExampleSubPushedView2Delegate <NSObject>

-(void)pushedDeleteButtonInPushedView:(ExampleSubPushedView2 *)sender;
-(void)tapTab:(ExampleSubPushedView2 *)sender;


@end

@interface ExampleSubPushedView2 : PATabbarPushedView
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak) UIViewController<ExampleSubPushedView2Delegate> *delegate;
@property (strong, nonatomic) UIViewController *controller;

@end
