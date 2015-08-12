//
//  VideosCell.m
//  Connotation
//
//  Created by qianfeng007 on 15-7-16.
//  Copyright (c) 2015年 轩哥. All rights reserved.
//

#import "VideosCell.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
@implementation VideosCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)showDataWithModel:(VideosModel *)model
{
    [self.videoImage sd_setImageWithURL:[NSURL URLWithString:model.vpic_middle] placeholderImage:[UIImage imageNamed: @"video_img_holder"]];
    self.title.text = model.wbody;
    self.time.text = [LZXHelper dateStringFromNumberTimer:model.update_time];
    [self.comment setTitle:[NSString stringWithFormat:@"评论:%ld",model.comments.integerValue] forState:UIControlStateNormal]; 
}

@end
