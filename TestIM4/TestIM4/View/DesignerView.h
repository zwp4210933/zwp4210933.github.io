//
//  DesignerView.h
//  TestIM4
//
//  Created by Apple on 15/12/31.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Designer.h"

/*这是业主查看到的视图*/

@interface DesignerView : UIView


-(instancetype)initWithFrame:(CGRect)frame Modle:(Designer *)model;

@end
