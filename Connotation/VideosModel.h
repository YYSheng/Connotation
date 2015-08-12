//
//  VideosModel.h
//  Connotation
//
//  Created by qianfeng007 on 15-7-16.
//  Copyright (c) 2015年 轩哥. All rights reserved.
//

#import "LZXModel.h"

@interface VideosModel : LZXModel
@property (nonatomic, copy) NSString *wid;
@property (nonatomic, copy) NSString *update_time;
@property (nonatomic, copy) NSString *wbody;
@property (nonatomic, copy) NSString *comments;
@property (nonatomic, copy) NSString *likes;
@property (nonatomic, copy) NSString *vpic_small;
@property (nonatomic, copy) NSString *vpic_middle;
@property (nonatomic, copy) NSString *vplay_url;
@property (nonatomic, copy) NSString *vsource_url;
@end
