//
//  ExampleSubPushedView.h
//  PATabbarView
//
//  Created by Inba on 2016/04/05.
//  Copyright © 2016年 Inba. All rights reserved.
//

#import "PATabbarPushedView.h"

@class ExampleSubPushedView;

@protocol ExampleSubPushedViewDelegate <NSObject>

-(void)pushedDeleteButtonInPushedView:(ExampleSubPushedView *)sender;
-(void)tapTab:(ExampleSubPushedView *)sender;


@end

@interface ExampleSubPushedView : PATabbarPushedView
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIView *bar;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak) UIViewController<ExampleSubPushedViewDelegate> *delegate;
@property (strong, nonatomic) UIViewController *controller;

@end
