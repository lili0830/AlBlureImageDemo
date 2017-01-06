//
//  ALBlurImageView.m
//  Tsinova_App
//
//  Created by 李丽 on 16/10/14.
//  Copyright © 2016年 LiLi. All rights reserved.
//

#import "ALBlurImageView.h"
#import <Accelerate/Accelerate.h>


@interface ALBlurImageView ()

@property (nonatomic, strong) UIImageView *backgroundImageView;


@end

@implementation ALBlurImageView

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self al_init];
        [self al_initSubViews];
    }
    return self;
}

- (void)al_init
{
    _initialBlurLevel = 0.9;
//    _originalImage = [UIImage imageNamed:@""];  //设置默认加载图
}

- (void) setOriginalImage:(UIImage *)originalImage
{
    _originalImage = originalImage;
    self.image = originalImage;
    
    dispatch_queue_t queue = dispatch_queue_create("BlurQueue", NULL);
    
    dispatch_async(queue, ^{
        UIImage *blurImage = [self appleBlurImage:originalImage withRadius:_initialBlurLevel];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _backgroundImageView.alpha = 0;
            _backgroundImageView.image = blurImage;
            
        });
    });
}

- (UIImage *)appleBlurImage:(UIImage *)blurImage withRadius:(CGFloat)blurRadius
{
    if ((blurRadius <= 0.0) || (blurRadius > 2.0)) {
        blurRadius = 1.0;
    }
    
    //blurRadius = 0.5;
    int boxSize = (int)(blurRadius * 100);   //boxSize = 50;
    boxSize -= (boxSize % 2) + 1; //24;
    
    CGImageRef rawImage = blurImage.CGImage;
    
    vImage_Buffer inBuffer , outBuffer;
    vImage_Error error;
    void *pixelBuffer;  //比特数
    
    CGDataProviderRef inprovider = CGImageGetDataProvider(rawImage);  //CGDataProviderRef  数据源提供者
    CFDataRef inBitmapData = CGDataProviderCopyData(inprovider);
    
    inBuffer.width = CGImageGetWidth(rawImage);
    inBuffer.height = CGImageGetHeight(rawImage);
    inBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
    inBuffer.data = (void *)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(rawImage) * CGImageGetHeight(rawImage));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(rawImage);
    outBuffer.height = CGImageGetHeight(rawImage);
    outBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"重绘图片 error ： %ld",error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef contentRef = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(blurImage.CGImage));
    
    CGImageRef imageRef = CGBitmapContextCreateImage(contentRef);
    UIImage *resultImage = [UIImage imageWithCGImage:imageRef];
    
    //claer
    CGContextRelease(contentRef);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    return resultImage;
}


//添加ScrollView 观察者
- (void) setScrollView:(UIScrollView *)scrollView
{
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    
    _scrollView = scrollView;
    
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self setblurLevel:self.scrollView.contentOffset.y / (CGRectGetHeight(self.bounds) * 3/8)];
    }
}

- (void) setblurLevel:(CGFloat)blurLevel
{
//    NSLog(@"blurLevel = %f",blurLevel);
    if (blurLevel < 0.0) {
        blurLevel = 0.0;
    }else if(blurLevel > 1.0){
        blurLevel = 1.0;
    }
    self.backgroundImageView.alpha = blurLevel;

}



- (void) al_initSubViews
{
    _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _backgroundImageView.alpha = 0;
    _backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    _backgroundImageView.backgroundColor = [UIColor clearColor];
    _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_backgroundImageView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
