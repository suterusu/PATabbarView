//
//  ExampleSubPushedView.m
//  PATabbarView
//
//  Created by Inba on 2016/04/05.
//  Copyright © 2016年 Inba. All rights reserved.
//

#import "ExampleSubPushedView.h"
#define ARC4RANDOM_MAX      0x100000000
@implementation ExampleSubPushedView{
    UIColor *_color;

}


-(void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor colorWithRed:randFloat(0.5, 1) green:randFloat(0.5, 1) blue:randFloat(0.5, 1) alpha:1];
    _color = self.backgroundColor;
}
- (IBAction)pushDeleteButton:(id)sender {
    [self.delegate pushedDeleteButtonOnView:self];
}

-(void)afterChangeState:(PATabbarPushedViewState)state{
    switch (state) {
        case PATabbarPushedViewStatusEmphasis:
            self.bar.hidden = NO;
            self.label.hidden = NO;
            self.backgroundColor = _color;
            break;
        default:
            self.label.hidden = YES;
            self.bar.hidden = YES;
            self.backgroundColor = [ExampleSubPushedView csn_colorWithBaseColor:_color brightnessRatio:0.5];
            break;
    }
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
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
