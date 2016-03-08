//
//  MediaView.h
//  TestIM4
//
//  Created by Apple on 16/1/8.
//  Copyright © 2016年 lanjue. All rights reserved.
//

#import <UIKit/UIKit.h>
/*这是多媒体视图，用于发送现拍和相册的照片以及快捷回复*/

@protocol MediaViewDelegate <NSObject>

-(void)openAlbum;
-(void)takePhoto;
-(void)callReplayView;

@end

@interface MediaView : UIView

@property (nonatomic, weak) id<MediaViewDelegate> delegate;

@end
