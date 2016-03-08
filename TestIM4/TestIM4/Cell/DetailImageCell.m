//
//  DetailImageCell.m
//  TestIM4
//
//  Created by Apple on 15/12/7.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "DetailImageCell.h"
#import "UIImageView+WebCache.h"
#import "ChatHistoryManager.h"

@interface DetailImageCell()<UIGestureRecognizerDelegate>

//当前缩放倍数
@property (nonatomic, assign) CGFloat curScale;
@property (nonatomic, assign) CGPoint imageCenter;
@property (nonatomic, strong) UIPanGestureRecognizer *panG;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation DetailImageCell

- (void)awakeFromNib {
    // Initialization code
}


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.curScale = 1;
        self.panG = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveImage:)];
        [self addObserver:self forKeyPath:@"curScale" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"imageCenter" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(void)dealloc{
    [self removeObserver:self forKeyPath:@"curScale"];
    [self removeObserver:self forKeyPath:@"imageCenter"];
}

-(void)configWithImageName:(NSString *)imageName imageSize:(CGSize)imageSize selfName:(NSString *)selfName friendName:(NSString *)friendName{
   
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    for (UIGestureRecognizer *g in self.gestureRecognizers) {
        [self removeGestureRecognizer:g];
    }
    CGSize imageViewSize = CGSizeMake( SCREEN_WIDTH , SCREEN_WIDTH*imageSize.height/imageSize.width);
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, imageViewSize.height)];
    NSString *topPath =[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/ChatHistory/%@/%@/Image",selfName,friendName]];
    if (imageName.length>20) {
        //网络图片进行下载
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",FileURL,imageName]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            ChatHistoryManager *manager = [[ChatHistoryManager alloc] init];
            //下载完成后保存图片到本地，并修改消息的内容为本地图片（缓存）
            manager.friendName = friendName;
            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
            [manager updateImageMessageOldName:imageName newName:[NSString stringWithFormat:@"RL%f",time]];
            NSString *topPath =[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/ChatHistory/%@/%@/Image",selfName,friendName]];
            NSString *fileName = [NSString stringWithFormat:@"%@/%@.jpg",topPath,[NSString stringWithFormat:@"RL%f",time]];
            [UIImageJPEGRepresentation(self.imageView.image, 0.75) writeToFile:fileName atomically:YES];
        }];
    }else{
        //本地图片直接获取
        UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.jpg",topPath,imageName]];
        self.imageView.image = image;
    }
    
        UIPinchGestureRecognizer *pinchG = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomImage:)];
        pinchG.delegate = self;
        [self.imageView addGestureRecognizer:pinchG];
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
        [self.imageView addGestureRecognizer:doubleTapGestureRecognizer];
        
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
        [singleTapGestureRecognizer setNumberOfTapsRequired:1];
        [self.contentView addGestureRecognizer:singleTapGestureRecognizer];
        
        [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
        
        self.imageView.userInteractionEnabled = YES;
        
        if (imageViewSize.height>[UIScreen mainScreen].bounds.size.height) {
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            scrollView.showsVerticalScrollIndicator = NO;
            [scrollView addSubview:self.imageView];
            
            scrollView.contentSize = imageViewSize;
            [self.contentView addSubview:scrollView];
        }else{
            
            self.imageView.center = self.contentView.center;
            [self.contentView addSubview:self.imageView];
        }
    

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    //根据被监听的变量修改各种手势的响应
    if ([keyPath isEqualToString:@"curScale"]) {
        CGFloat curScale = [change[@"new"] floatValue];
        if (curScale==1) {
            ((UICollectionView *)self.superview).scrollEnabled = YES;
            [self.imageView removeGestureRecognizer:self.panG];
            if([self.imageView.superview isKindOfClass:[UIScrollView class]]){
                ((UIScrollView *)self.imageView.superview).scrollEnabled = YES;
            }
        }else{
            ((UICollectionView *)self.superview).scrollEnabled = NO;
            [self.imageView addGestureRecognizer:self.panG];
            if([self.imageView.superview isKindOfClass:[UIScrollView class]]){
                ((UIScrollView *)self.imageView.superview).scrollEnabled = NO;
            }
        }

    }else{
        CGPoint center = [change[@"new"] CGPointValue];
        if (center.x==[UIScreen mainScreen].bounds.size.width-self.imageView.bounds.size.width*self.imageView.transform.a/2||center.x==self.imageView.bounds.size.width*self.imageView.transform.a/2) {
            ((UICollectionView *)self.superview).scrollEnabled = YES;
        }else{
            ((UICollectionView *)self.superview).scrollEnabled = NO;
        }
    }
}



//缩放手势
-(void)zoomImage:(UIPinchGestureRecognizer *)g{
    UIImageView *imageView = (UIImageView *)g.view;
    CGFloat scale = g.scale;
    if (scale>0.5&&scale<3) {
        imageView.transform = CGAffineTransformScale(CGAffineTransformMake(self.curScale, 0, 0, self.curScale, 0, 0), scale, scale);
        imageView.center = self.contentView.center;
    }
    if (g.state == UIGestureRecognizerStateEnded) {
        if (imageView.transform.a<1) {
            [UIView animateWithDuration:0.3 animations:^{
                imageView.transform = CGAffineTransformMakeScale(1, 1);
                if ([imageView.superview isKindOfClass:[UIScrollView class]]) {
                    imageView.center = CGPointMake(self.contentView.center.x, imageView.bounds.size.height/2);
                }
            }];
            
        }else if(imageView.transform.a>2){
            [UIView animateWithDuration:0.3 animations:^{
                imageView.transform = CGAffineTransformMakeScale(2, 2);
            }];
        }
        self.curScale = imageView.transform.a;
    }
}

//移动图片手势，放大状态下激活
-(void)moveImage:(UIPanGestureRecognizer *)g{
    if (g.view.transform.a>1) {
        CGPoint offsetPoint = [g translationInView:self.contentView];
        CGPoint oldCenter = g.view.center;
        NSLog(@"%f,%f",oldCenter.x,g.view.bounds.size.width/2);
        CGFloat newX;
        CGFloat newY;
        if (oldCenter.x+offsetPoint.x>g.view.bounds.size.width*g.view.transform.a/2) {
            newX = g.view.bounds.size.width*g.view.transform.a/2;
            ((UICollectionView *)self.superview).scrollEnabled = YES;
        }else if (oldCenter.x+offsetPoint.x<[UIScreen mainScreen].bounds.size.width-g.view.bounds.size.width*g.view.transform.a/2){
            newX = [UIScreen mainScreen].bounds.size.width-g.view.bounds.size.width*g.view.transform.a/2;
            ((UICollectionView *)self.superview).scrollEnabled = YES;
        }else{
            newX = oldCenter.x +offsetPoint.x;
            ((UICollectionView *)self.superview).scrollEnabled = NO;
        }
        if (oldCenter.y+offsetPoint.y>g.view.bounds.size.height*g.view.transform.a/2) {
            newY = g.view.bounds.size.height*g.view.transform.a/2;
        }else if (oldCenter.y+offsetPoint.y<[UIScreen mainScreen].bounds.size.height-g.view.bounds.size.height*g.view.transform.a/2){
            newY = [UIScreen mainScreen].bounds.size.height-g.view.bounds.size.height*g.view.transform.a/2;
        }else{
            newY = oldCenter.y +offsetPoint.y;
        }
        if (g.view.bounds.size.height*g.view.transform.a<[UIScreen mainScreen].bounds.size.height) {
            newY = oldCenter.y;
        }
        g.view.center = CGPointMake(newX, newY);
        self.imageCenter = g.view.center;
        [g setTranslation:CGPointZero inView:self.contentView];
    }
}

//双击放大手势
-(void)doubleTap:(UITapGestureRecognizer *)g{
    if (g.view.transform.a>1.5) {
        [UIView animateWithDuration:0.3 animations:^{
            self.imageView.transform = CGAffineTransformMakeScale(1, 1);
            if ([self.imageView.superview isKindOfClass:[UIScrollView class]]) {
                self.imageView.center = CGPointMake(self.contentView.center.x, self.imageView.bounds.size.height/2);
            }else{
                self.imageView.center = self.contentView.center;
            }
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.imageView.transform = CGAffineTransformMakeScale(2, 2);
        }];
    }
    self.curScale = self.imageView.transform.a;
}

//单机退出手势
-(void)singleTap:(UITapGestureRecognizer *)g{

    [self.delegate goBackToLastCtrl];
}

@end
