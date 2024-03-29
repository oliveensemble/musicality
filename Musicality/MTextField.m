//
//  MTextField.m
//  Musicality
//
//  Created by Elle Lewis on 7/23/16.
//  Copyright © 2016 Later Creative LLC. All rights reserved.
//

#import "MTextField.h"

@interface MTextField()

@property (nonatomic,strong) UIColor *colorButtonClearHighlighted;
@property (nonatomic,strong) UIColor *colorButtonClearNormal;

@property (nonatomic,strong) UIImage *imageButtonClearHighlighted;
@property (nonatomic,strong) UIImage *imageButtonClearNormal;

@end

@implementation MTextField

- (void)layoutSubviews {
  [super layoutSubviews];
  [self tintButtonClear];
}

- (void)setColorButtonClearHighlighted:(UIColor *)colorButtonClearHighlighted {
  _colorButtonClearHighlighted = colorButtonClearHighlighted;
}

- (void)setColorButtonClearNormal:(UIColor *)colorButtonClearNormal {
  _colorButtonClearNormal = colorButtonClearNormal;
}

- (UIButton *)buttonClear {
  for(UIView *v in self.subviews) {
    if([v isKindOfClass:[UIButton class]]) {
      UIButton *buttonClear = (UIButton *) v;
      return buttonClear;
    }
  }
  return nil;
}

- (void)tintButtonClear {
  UIButton *buttonClear = [self buttonClear];
  
  if(self.colorButtonClearNormal && self.colorButtonClearHighlighted && buttonClear) {
    UIImage *imageHighlighted = [buttonClear imageForState:UIControlStateHighlighted];
    self.imageButtonClearHighlighted = [[self class] imageWithImage:imageHighlighted tintColor:self.colorButtonClearHighlighted];
    
    UIImage *imageNormal = [buttonClear imageForState:UIControlStateNormal];
    self.imageButtonClearNormal = [[self class] imageWithImage:imageNormal tintColor:self.colorButtonClearNormal];
    
    if(self.imageButtonClearHighlighted && self.imageButtonClearNormal) {
      [buttonClear setImage:self.imageButtonClearHighlighted forState:UIControlStateHighlighted];
      [buttonClear setImage:self.imageButtonClearNormal forState:UIControlStateNormal];
    }
  }
}

+ (UIImage *)imageWithImage:(UIImage *)image tintColor:(UIColor *)tintColor {
  UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGRect rect = (CGRect){ CGPointZero, image.size };
  CGContextSetBlendMode(context, kCGBlendModeNormal);
  [image drawInRect:rect];
  
  CGContextSetBlendMode(context, kCGBlendModeSourceIn);
  [tintColor setFill];
  CGContextFillRect(context, rect);
  
  UIImage *imageTinted  = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return imageTinted;
}

@end
