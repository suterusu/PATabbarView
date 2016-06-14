//
//  ExampleSubPushedView2.m
//  PATabbarView
//
//  Created by Inba on 2016/06/14.
//  Copyright © 2016年 Inba. All rights reserved.
//

#import "ExampleSubPushedView2.h"
#define ARC4RANDOM_MAX      0x100000000


@implementation ExampleSubPushedView2{
    UIColor *_color;
    
}



-(void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor colorWithRed:randFloat(0.5, 1) green:randFloat(0.5, 1) blue:randFloat(0.5, 1) alpha:1];
    _color = self.backgroundColor;
}


- (IBAction)pushDeleteButton:(id)sender {
    [self.delegate pushedDeleteButtonInPushedView:self];
}

-(void)afterChangeState:(PATabbarPushedViewState)state{
    switch (state) {
        case PATabbarPushedViewStatusEmphasis:
            self.label.hidden = NO;
            self.backgroundColor = _color;
            break;
        default:
            self.label.hidden = YES;
            self.backgroundColor = [ExampleSubPushedView2 csn_colorWithBaseColor:_color brightnessRatio:0.5];
            break;
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.delegate tapTab:self];
}


float randFloat(float a, float b)
{
    return ((b-a)*((float)arc4random()/ARC4RANDOM_MAX))+a;
}

+ (UIColor *)csn_colorWithBaseColor:(UIColor *)baseColor brightnessRatio:(CGFloat)ratio
{
    CGFloat hue = 0;
    CGFloat saturation = 0;
    CGFloat brightness = 0;
    CGFloat alpha = 0;
    
    BOOL converted = [baseColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    if (converted) {
        return [UIColor colorWithHue:hue saturation:saturation brightness:(brightness * ratio) alpha:alpha];
    }
    
    return nil;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
