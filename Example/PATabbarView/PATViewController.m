//
//  PATViewController.m
//  PATabbarView
//
//  Created by Inba on 04/05/2016.
//  Copyright (c) 2016 Inba. All rights reserved.
//

#import "PATViewController.h"
#import "ExampleViewController.h"

@interface PATViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabbarHeight;
@property (weak, nonatomic) IBOutlet PATabbarView *tabbar;
@property (weak, nonatomic) IBOutlet UIView *baseView;
@end

@implementation PATViewController{
    ExampleSubPushedView *_currentCenter;
    CGFloat _firstTabbarHeight;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _firstTabbarHeight = self.tabbarHeight.constant;
    self.tabbar.delegate = self;
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)setCurrentCenter:(ExampleSubPushedView *)nextCenter{
    if ([_currentCenter isEqual:nextCenter]) {
        return;
    }
    if (_currentCenter) {
        _currentCenter.deleteButton.hidden = YES;
    }
    _currentCenter = nextCenter;
    nextCenter.deleteButton.hidden = NO;
}


- (IBAction)pushAddTabButton:(id)sender {
    static int vcNum = 1;
    UINib *nib = [UINib nibWithNibName:@"ExampleSubPushedView" bundle:nil];
    ExampleSubPushedView *pushedView=  [nib instantiateWithOwner:nil options:nil][0];
    pushedView.delegate = self;
    pushedView.controller = [self newVCOpen];
    pushedView.controller.view.backgroundColor = pushedView.backgroundColor;
    [pushedView.label setText:[NSString stringWithFormat:@"%d",vcNum]];
    [self setCurrentCenter:pushedView];
    [self.tabbar addToTailView:pushedView];
    vcNum++;
}



-(void)tapTab:(ExampleSubPushedView *)sender{
    if (sender.currentState == PATabbarPushedViewStatusEmphasis) {
        if ([sender isEqual:_currentCenter]) {
            return;
        }
        [self changeVCTo:sender.controller From:_currentCenter.controller];
        [self setCurrentCenter:sender];
    }else{
        _currentCenter.deleteButton.hidden = YES;
        [self.tabbar adjustPositionWithAForcusOnView:sender];
    }
}

-(void)pushedDeleteButtonInPushedView:(ExampleSubPushedView *)sender{
    if (sender == _currentCenter) {
        if ((sender.next)||(sender.prev)) {
            ExampleSubPushedView *next = sender.next ?:sender.prev;
            [self changeVCTo:next.controller From:_currentCenter.controller];//交換
            [self setCurrentCenter:next];
        }else{
            _currentCenter = nil;
            [self deleteFromParentAtVC:sender.controller];
        }
    }
    
    sender.controller = nil;
    [_tabbar deleteView:sender];
}

-(UIViewController *)newVCOpen{
    ExampleViewController *newVC = [[ExampleViewController alloc]init];
    newVC.view.frame = self.baseView.frame;
    
    UIViewController *nextChildVC;
    if (_currentCenter) {
        nextChildVC = [self changeVCTo:newVC From:_currentCenter.controller];
    }else{
        [self addChildViewController:newVC];
        [self.view addSubview:newVC.view];
        [newVC didMoveToParentViewController:self];
        nextChildVC = newVC;
    }
    return nextChildVC;
}

-(UIViewController *)changeVCTo:(UIViewController *)toVC From:(UIViewController *)fromVC{
    [self addChildViewController:toVC];
    [fromVC willMoveToParentViewController:nil];
    [self transitionFromViewController:fromVC toViewController:toVC duration:0 options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
        [toVC didMoveToParentViewController:self];
        [fromVC removeFromParentViewController];
    }];
    return toVC;
}

-(void)deleteFromParentAtVC:(UIViewController *)deleteVC{
    [deleteVC willMoveToParentViewController:nil];
    [deleteVC removeFromParentViewController];
    [deleteVC.view removeFromSuperview];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
