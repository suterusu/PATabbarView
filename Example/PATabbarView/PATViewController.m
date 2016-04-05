//
//  PATViewController.m
//  PATabbarView
//
//  Created by Inba on 04/05/2016.
//  Copyright (c) 2016 Inba. All rights reserved.
//

#import "PATViewController.h"
#import "ExampleSubPushedView.h"

@interface PATViewController ()
@property (weak, nonatomic) IBOutlet PATabbarView *tabbar;
@end

@implementation PATViewController{
    ExampleSubPushedView *_currentCenter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)pushToTabbar:(id)sender {
    UINib *nib = [UINib nibWithNibName:@"ExampleSubPushedView" bundle:nil];
    ExampleSubPushedView *pushedView=  [nib instantiateWithOwner:nil options:nil][0];
    pushedView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.tabbar addToTailView:pushedView];
}


-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    PATabbarPushedView *touchedView = [self.view hitTest:point withEvent:nil];
    if ([touchedView isKindOfClass:[ExampleSubPushedView class]]== NO) {
        return;
    }
    if ([_currentCenter isEqual:touchedView]) {
        [_tabbar deleteView:_currentCenter];
        return;
    }
    switch (touchedView.currentState) {
        case PATabbarPushedViewStatusEmphasis:{
            for (PATabbarPushedView *push = self.tabbar.head; push; push = push.next) {
                push.layer.borderWidth = 0;
            }
            touchedView.layer.borderWidth = 2;
            _currentCenter = touchedView;
            break;}
        case PATabbarPushedViewStatusDisplayed:{
            [self.tabbar adjustPositionWithAForcusOnView:touchedView];
            break;}
    }
}

-(void)finishedAdjustAnimationAtForcusedView:(PATabbarPushedView *)forcusedView{
    for (PATabbarPushedView *push = self.tabbar.head; push; push = push.next) {
        push.layer.borderWidth = 0;
    }
    _currentCenter.layer.borderWidth = 2;
    _currentCenter = forcusedView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
