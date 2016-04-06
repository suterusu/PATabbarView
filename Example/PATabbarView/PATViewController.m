//
//  PATViewController.m
//  PATabbarView
//
//  Created by Inba on 04/05/2016.
//  Copyright (c) 2016 Inba. All rights reserved.
//

#import "PATViewController.h"

@interface PATViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabbarHeight;
@property (weak, nonatomic) IBOutlet PATabbarView *tabbar;
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
- (IBAction)pushToTabbar:(id)sender {
    if (self.tabbarHeight.constant == 0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.tabbarHeight.constant = _firstTabbarHeight;
            [self.view layoutIfNeeded];
        }];
    }
    UINib *nib = [UINib nibWithNibName:@"ExampleSubPushedView" bundle:nil];
    ExampleSubPushedView *pushedView=  [nib instantiateWithOwner:nil options:nil][0];
    pushedView.delegate = self;
    pushedView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.tabbar addToTailView:pushedView];
}


-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    ExampleSubPushedView *touchedView = [self.view hitTest:point withEvent:nil];
    if ([touchedView isKindOfClass:[ExampleSubPushedView class]]== NO) {
        return;
    }

    switch (touchedView.currentState) {
        case PATabbarPushedViewStatusEmphasis:{
            for (ExampleSubPushedView *push = self.tabbar.head; push; push = push.next) {
                push.deleteButton.alpha = 0;
            }
            touchedView.deleteButton.alpha = 1;
            _currentCenter = touchedView;
            break;}
        case PATabbarPushedViewStatusDisplayed:{
            [self.tabbar adjustPositionWithAForcusOnView:touchedView];
            break;}
    }
}

-(void)finishedAdjustAnimationAtForcusedView:(PATabbarPushedView *)forcusedView{
    for (ExampleSubPushedView *push = self.tabbar.head; push; push = push.next) {
        push.deleteButton.alpha = 0;
    }
    _currentCenter = (ExampleSubPushedView *)forcusedView;
}

-(void)deletedLastPushedView{
    [UIView animateWithDuration:0.5 animations:^{
        self.tabbarHeight.constant = 0;
        [self.view layoutIfNeeded];
    }];

}

//ExampleSubPushedView.h
-(void)pushedDeleteButtonOnView:(ExampleSubPushedView *)view{
    [self.tabbar deleteView:view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
