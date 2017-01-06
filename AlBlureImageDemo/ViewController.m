//
//  ViewController.m
//  AlBlureImageDemo
//
//  Created by 李丽 on 17/1/5.
//  Copyright © 2017年 LiLi. All rights reserved.
//

#import "ViewController.h"
#import "ALBlurImageView.h"

@interface ViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) ALBlurImageView *blurImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.delegate = self;
    
    self.blurImageView = [[ALBlurImageView alloc] initWithFrame:self.view.bounds];
    self.blurImageView.scrollView = self.scrollView;
    self.blurImageView.originalImage = [UIImage imageNamed:@"Consultation_Top"];
    self.blurImageView.initialBlurLevel = 1.5;
    [self.view addSubview:self.blurImageView];
    
    [self.view addSubview:self.scrollView];
    
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height * 3);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
