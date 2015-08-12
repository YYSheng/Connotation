//
//  VideosCell.h
//  Connotation
//
//  Created by qianfeng007 on 15-7-16.
//  Copyright (c) 2015年 轩哥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideosModel.h"

@interface VideosCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *videoImage;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UIButton *comment;


//保存model
@property (nonatomic,strong) VideosModel *model;
//分类
@property (nonatomic,copy) NSString *category;



//填充cell
- (void)showDataWithModel:(VideosModel *)model;

@end
