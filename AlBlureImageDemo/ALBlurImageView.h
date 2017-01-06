//
//  ALBlurImageView.h
//  Tsinova_App
//
//  Created by 李丽 on 16/10/14.
//  Copyright © 2016年 LiLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALBlurImageView : UIImageView

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) float initialBlurLevel;

@end
