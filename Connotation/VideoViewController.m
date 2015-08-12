//
//  VideoViewController.m
//  Connotation
//
//  Created by LZXuan on 15-7-14.
//  Copyright (c) 2015年 轩哥. All rights reserved.
//

#import "VideoViewController.h"
#import "JHRefresh.h"
#import "CommentViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#define kCellId @"VideosCell"
#define kScreenSize [UIScreen mainScreen].bounds.size
@interface VideoViewController ()
{
    //可以播放视频的视图控制器 MP4 avi wov m3u8(流媒体)
    //本地 / 远程
    MPMoviePlayerViewController *_mpVC;
}
@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //取消 透明 的导航条或者 tabBar 对 滚动视图的影响
    self.automaticallyAdjustsScrollViewInsets = NO;
    //初始化
    self.isRefreshing = NO;
    self.isLoadMore = NO;
    self.currentPage = 0;//开始第0页
    self.max_timestamp = @"-1";
    
    [self createTableView];
    [self createRequest];
    //下载第一页数据
    [self loadDataWithPage:self.currentPage count:30];
    //创建 刷新
    [self createRefreshView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 刷新
- (void)createRefreshView {
    //下拉刷新 给scrollView 增加的类别 增补的方法
    //arc 下 防止 两个强引用 导致 内存泄露
    //写一个弱引用指针 weakSelf 这样在block 中就不会 强引用
    __weak typeof(self)weakSelf = self;
    
    [self.tableView addRefreshHeaderViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        //只要下拉刷新就会 回调这个block
        if (weakSelf.isRefreshing) {
            //正在刷新 直接返回
            return ;
        }
        weakSelf.isRefreshing = YES;
        weakSelf.currentPage = 0;
        weakSelf.max_timestamp = @"-1";
        //下拉 刷新  第 0 页 30条
        [weakSelf loadDataWithPage:weakSelf.currentPage count:30];
    }];
    
    //上拉加载
    [self.tableView addRefreshFooterViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        //上拉 会 回调这个block
        if (weakSelf.isLoadMore) {
            return ;
        }
        weakSelf.isLoadMore = YES;
        weakSelf.currentPage++;//页码+1
        //上拉加载的时候max_timestamp 应该是最后一条数据的时间
        VideosModel *model = [weakSelf.dataArr lastObject];
        weakSelf.max_timestamp = model.update_time;
        //重新下载
        [weakSelf loadDataWithPage:weakSelf.currentPage count:15];
        
    }];
}
//结束刷新
- (void)endRefreshing {
    if (self.isRefreshing) {
        self.isRefreshing = NO;
        [self.tableView headerEndRefreshingWithResult:JHRefreshResultSuccess];
    }
    if (self.isLoadMore) {
        self.isLoadMore = NO;
        [self.tableView footerEndRefreshing];
    }
}



#pragma mark - 表格
- (void)createTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height-64-49) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    //注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"VideosCell" bundle:nil] forCellReuseIdentifier:kCellId];
}
#pragma mark - 下载对象
- (void)createRequest {
    _manager = [AFHTTPRequestOperationManager manager];
    //设置 响应 格式 二进制 不解析
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //数据源数组
    self.dataArr = [[NSMutableArray alloc] init];
}
#pragma mark - 下载数据解析数据
- (void)loadDataWithPage:(NSInteger)page count:(NSInteger)count {
    NSString *url = [NSString stringWithFormat:kContentUrl,self.category,page,count,self.max_timestamp];
    //get请求下载
    //防止 两个强引用 导致死锁 内存泄露
    __weak typeof(self) weakSelf = self;
    
    [_manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"下载成功");
        if (responseObject) {
            if (weakSelf.currentPage == 0 ) {
                //如果刷新的是第0页 那么要删除之前
                [weakSelf.dataArr removeAllObjects];
            }
            //解析数据 json
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSArray *itemArr = dict[@"items"];
            //遍历数组
            for (NSDictionary*itemDict in itemArr) {
                //把字典的数据存放在 model 中
                VideosModel *model= [[VideosModel alloc] init];
                //kvc 进行赋值--》根据字典 依次对model 的属性赋值
                [model setValuesForKeysWithDictionary:itemDict];
                //等价于下面的 依次赋值
                /*
                 model.wid = dict[@"wid"];
                 model.wbody = dict[@"wbody"];
                 ....
                 */
                //存到数据源
                [weakSelf.dataArr addObject:model];
            }
            //数据源变了 那么要刷新
            [weakSelf.tableView reloadData];
            //下载完成了 要结束刷新
            [weakSelf endRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"下载失败");
        [weakSelf endRefreshing];
    }];
    
}
#pragma mark - TableView协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VideosCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    VideosModel *model = self.dataArr[indexPath.row];
    //填充
    //把 分类传给 cell
    cell.category = self.category;
    [cell showDataWithModel:model];
    
    return cell;
}
//动态的计算 cell 的行高
//label 和 图片的高度 不一样
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideosModel *model = self.dataArr[indexPath.row];
    NSString *url = model.vplay_url;
    [self createVideoWithPath:url];
}
- (void)createVideoWithPath:(NSString *)path {
    
    NSURL *url = nil;
    if ([path hasPrefix:@"http://"]||[path hasPrefix:@"https://"]) {
        //网络视频
        url = [NSURL URLWithString:path];//加载网络地址 转化为NSURL
    }else{
        url = [NSURL fileURLWithPath:path];//把本地文件路径转化为NSURL
    }
    
    //注册一个观察者对象 监听 视频是否播放完毕(1.点击Done 2.正常播放完 3.异常)
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoBack:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    if (!_mpVC) {
        //实例化
        _mpVC = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        //MPMoviePlayerViewController内部 有 一个MPMoviePlayerController来控制视频的播放
        //是否允许自动播放
        _mpVC.moviePlayer.shouldAutoplay = YES;
    }
    //播放
    [_mpVC.moviePlayer play];
    
    //模态跳转
    [self presentViewController:_mpVC animated:YES completion:nil];
    //或者
    //[self presentMoviePlayerViewControllerAnimated:_mpVC];
}
- (void)playVideoBack:(NSNotification *)nf {
    NSLog(@"播放完毕");
//    NSLog(@"info:%@",nf.userInfo);
    //获取返回的原因
    NSInteger type = [nf.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    if (type == 0) {
        NSLog(@"正常结束返回");
    }else if(type == 1) {
        NSLog(@"异常");
    }else if (type == 2) {
        NSLog(@"点击Done 返回");
    }
    if (_mpVC) {
        [_mpVC.moviePlayer stop];//停止
        _mpVC = nil;
    }
    //用完观察者要删除
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    //模态跳转返回
    [_mpVC dismissViewControllerAnimated:YES completion:nil];
}

@end
