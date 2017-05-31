//
//  RefundResultViewController.m
//  CloudTiger
//
//  Created by cyan on 16/10/16.
//  Copyright © 2016年 cyan. All rights reserved.
//

#import "RefundResultViewController.h"
#import "SBJsonWriter.h"
#import "QueryResultCell.h"
#import "QueryResultModel.h"
#import "QueryOrderViewController.h"
#import "RefundDesViewController.h"
#import "QueryRefundNewCell2.h"
//#import "RefundQueryNewModel.h"
#import "RefudDesModel.h"
#import "RefundQueryDesVC.h"
#import "CyanLoadFooterView.h"

@interface RefundResultViewController ()<UITableViewDelegate,UITableViewDataSource,RefundListDelegate>{
    NSMutableArray *_queryResultArr;
    NSInteger _page;
    NSString *_postUrl;
    BOOL _isMove;
    
}
@property(nonatomic,strong)UITableView *table;

@end
@implementation RefundResultViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = PaleColor;
    [self setViewTitle];
    
    [self.view addSubview:self.table];
    self.table.hidden = YES;
    /**底部返回首页按钮*/
    [self homeBtnView];
    
    [self initConfigure];
    [self getUrlAndParameters];
    //退款 用 RefudDesModel.h model
    [self postData];
}
/**
 设置 标题
 */
-(void)setViewTitle{
    switch (self.queryState) {
        case kQueryOrder://订单 - 列表
        {
            self.title = @"订单查询";
        }
            break;
            
        case kQueryRefund://退款 - 列表
        {
            self.title = @"退款";
            
        }
            break;
            
            
        case kQueryRefundOrder://退款查询 - 列表
        {
            self.title = @"退款查询";
            
        }
            break;
            
        default:
            break;
    }
    
    
    
}

-(void)getUrlAndParameters{
    NSNumber *number = [NSNumber numberWithInteger:_page];
    NSNumber *number2 = @20;
    NSDictionary *pageDic = @{
                              @"PageNumber":number,
                              @"PageSize":number2
                              };
    //    NSDictionary *pageDic = [NSDictionary new];
    
    
    [self.paramters setObject:pageDic forKey:@"PagingInfo"];
    //    [self.paramters setObject:@"2016-09-12" forKey:@"Time_Start"];
    //    [self.paramters setObject:@"2016-09-11" forKey:@"Time_end"];
    
    
    //    Pay_Type
    //    [parameter setObject:@"102" forKey:@"Pay_Type"];
    
    /**
     订单查询
     退款查询
     退款
     */
    NSString *url = @"";
    NSLog(@"queryState :%d",self.queryState);
    CyanManager *cyManager = [CyanManager shareSingleTon];
    if (self.queryState == kQueryOrder ) {
#pragma mark 判断 进入 员工进
        
        //            kOrderShop   = 0,//商户订单查询
        //            kOrderShopUser        =  10,//商户员工订单查询
        //            kOrderCustomer   = 20 ,//服务商订单查询
        //            kOrderCustomerUser = 30//服务商员工订单查询
        switch (self.queryOrderState) {
            case kOrderShop:
            {
                url = [BaseUrl stringByAppendingString:QueryOrderShopUrl];
                [self.paramters setObject:cyManager.sysNO forKey:@"CustomerSysNo"];
            }
                break;
                
            case kOrderShopUser:
            {
                
                
                url = [BaseUrl stringByAppendingString:QueryOrderShopUserUrl];
                /**
                 //商户下员工  需要判断
                 如果 userSysNo 不是空说明是在商户下查询员工
                 */
                if (self.userSysNo.length) {
                    [self.paramters setObject:self.userSysNo forKey:@"SystemUserSysNo"];
                    
                }else{
                    [self.paramters setObject:cyManager.sysNO forKey:@"SystemUserSysNo"];
                    
                    
                }
                
            }
                break;
            case kOrderCustomer:
            {
                url = [BaseUrl stringByAppendingString:QueryOrderCustomerUrl];
                
                [self.paramters setObject:cyManager.sysNO forKey:@"CustomersTopSysNo"];
            }
                break;
            case kOrderCustomerUser:
            {
                url = [BaseUrl stringByAppendingString:QueryOrderCustomerUserUrl];
                [self.paramters setObject:cyManager.sysNO forKey:@"SystemUserTopSysNo"];
                
                [self.paramters setObject:cyManager.shopSysNo forKey:@"CustomersTopSysNo"];
            }
                break;
            default:
                break;
        }
        
        
    }
    else if (self.queryState == kQueryRefund){
        url = [BaseUrl stringByAppendingString:QureyRefundUrl];
        [self.paramters setObject:cyManager.sysNO forKey:@"SystemUserSysNo"];
        
        
    }else{
        url = [BaseUrl stringByAppendingString:QueryRefundOrderUrl];
        [self.paramters setObject:cyManager.sysNO forKey:@"SystemUserSysNo"];
        
    }
    /**
     保存一下
     */
    _postUrl = url;
}

-(void)postData{
    
    [self showSVPByStatus:@"加载中..."];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //申明请求的数据是json类型
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    //    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer =  [AFJSONResponseSerializer serializer];
    //设置请求头 压缩
    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [manager.requestSerializer setTimeoutInterval:15];
    
    
//    
//    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
//    NSString *json = [writer stringWithObject:self.paramters];
    
    [manager POST:_postUrl parameters:self.paramters progress:^(NSProgress * _Nonnull uploadProgress) {
        //        NSLog(@"uploadProgress :%@",uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self dismissSVP];
        self.table.hidden = NO;
        //底部试图显示出来
        _table.footer.hidden = NO;
        
        [self endRefreshing];
        
        NSLog(@"responseObject :%@",responseObject);
        NSArray *model = responseObject[@"model"];
        if (!model.count) {
            NSLog(@"没有数据");
            if (_page == 0) {//第一次请求，没有数据提示 查无数据
                [MessageView showMessage:@"查无数据"];
                
            }
            _isMove = YES;
            _table.footer.hidden = YES;
            //            _table.footer.state = MJRefreshFooterStateNoMoreData;
        }else{
            if (model.count < 20) {
                _isMove = YES;
                _table.footer.hidden = YES;
            }
            
            //            _queryResultArr  =[ NSMutableArray new];
            for (NSDictionary* dic in model) {
                
                RefudDesModel *refunModel = [[ RefudDesModel alloc]init];
                [refunModel setValuesForKeysWithDictionary:dic];
                
                
                refunModel.refund_fee = dic[@"fee"];
                
                NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
                NSTimeInterval dis = [date timeIntervalSince1970];
                NSString *time = [CyTools getYearAndMonthAndDayByTimeInterval:dis];
                NSString *time2 = [CyTools  getYearAndMonthByYear:refunModel.Time_Start];
                if ([time2  isEqualToString:time]) {
                    //                refundBtn.backgroundColor = UIColorFromRGB(0x26a005, 1);
                    //可退金额小于  总金额 为部分退款 ；可退金额 ==  总金额  为退款
                    NSInteger totalMoney = [refunModel.Cash_fee integerValue];
                    NSInteger refunMoney = [refunModel.refund_fee integerValue];
                    
                    if (refunMoney == totalMoney) {
                        refunModel.refundStatus = @"退款";
                        //                 [refundBtn setTitle:@"退款" forState:UIControlStateNormal];
                    }else if(refunMoney ==  0){
                        refunModel.refundStatus = @"退款完成";
                        //                 [refundBtn setTitle:@"退款完成" forState:UIControlStateDisabled];
                        
                    }else{
                        refunModel.refundStatus = @"部分退款";
                        //                 [refundBtn setTitle:@"部分退款" forState:UIControlStateNormal];
                    }
                    
                }else{
                    //                不可退款
                    refunModel.refundStatus = @"不可退款";
                }
                
                [_queryResultArr addObject:refunModel];
            }
            
            
        }
        
        /** 最后刷新页面 */
        [self.table reloadData];
        NSLog(@"count :%ld",model.count);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self dismissSVP];
        if (error.code ==  -1009) {
            
            NSLog(@"没有网络了");
        }
        IsNilOrNull(error.userInfo[@"NSLocalizedDescription"])?   [MessageView showMessage:@"网络错误"]:   [MessageView showMessage:error.userInfo[@"NSLocalizedDescription"]];
        NSLog(@"error :%@",error);
    }];
}
#pragma mark --- table
-(UITableView *)table{
    if (!_table) {
        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, MainScreenWidth, MainScreenHeight -64) style:UITableViewStyleGrouped];
        
        [_table registerClass:[QueryResultCell class] forCellReuseIdentifier:@"QueryResultCell"];
        [_table registerClass:[QueryRefundNewCell2 class] forCellReuseIdentifier:@"QueryRefundNewCell2"];
        [_table registerClass:[CyanLoadFooterView class] forHeaderFooterViewReuseIdentifier:@"CyanLoadFooterView"];
        
        _table.delegate = self;
        _table.dataSource = self;
        _table.backgroundColor =PaleColor;
        //去掉头部留白
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.001)];
        view.backgroundColor = [UIColor redColor];
        _table.tableHeaderView = view;
        //去掉边线
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _table;
}
-(void)initConfigure{
    [self.table  addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [self.table.footer  setTitle:@"加载更多" forState:MJRefreshFooterStateIdle];
    [self.table.footer  setTitle:@"暂无更多数据" forState:MJRefreshFooterStateNoMoreData];
    
    
    [self.table addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(reloadDATA)];
    [self.table.header setTitle:@"下拉刷新" forState:MJRefreshHeaderStateIdle];
    _page = 0;
    _queryResultArr = [NSMutableArray new];
}
#pragma mark ---  加载更多
-(void)loadMoreData{
    _page ++;
    NSNumber *number = [NSNumber numberWithInteger:_page];
    NSNumber *number2 = @20;
    NSDictionary *pageDic = @{
                              @"PageNumber":number,
                              @"PageSize":number2
                              };
    //    NSDictionary *pageDic = [NSDictionary new];
    
    
    [self.paramters setObject:pageDic forKey:@"PagingInfo"];
    
    //    if (_page >5) {
    //
    //        _table.footer.state = MJRefreshFooterStateNoMoreData;
    //
    //
    //        return;
    //    }
    //
    
    
    [self postData];
    
}
-(void)endRefreshing{
    
    [self.table.footer endRefreshing];
    [self.table.header endRefreshing];
}
/**
 下拉头刷新
 */
-(void)reloadDATA{
    _page = 0;
    _queryResultArr = [NSMutableArray new];
    _isMove = NO;
    _table.footer.hidden = YES;
    [self.table reloadData];
    NSNumber *number = [NSNumber numberWithInteger:0];
    NSNumber *number2 = @20;
    NSDictionary *pageDic = @{
                              @"PageNumber":number,
                              @"PageSize":number2
                              };
    
    
    
    [self.paramters setObject:pageDic forKey:@"PagingInfo"];
    NSLog(@"下拉刷新");
    //    [self endRefreshing];
    
    
    
    
    [self postData];
}

#pragma  mark UITableViewDataSource
//组个数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//单元格个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _queryResultArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    QueryRefundNewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"QueryRefundNewCell2" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.refudDesModel = _queryResultArr[indexPath.row];
    return cell;
    
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击了。。");
    
    
    RefundDesViewController *query = [RefundDesViewController new];
    RefudDesModel *model = _queryResultArr[indexPath.row];
    query.queryResultModel = model;
    query.delegete = self;
    query.indexPath = indexPath;
    [self.navigationController pushViewController:query animated:YES];
    
}


//单元格高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60 +21;
    
}


////组尾
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_isMove) {
        CyanLoadFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"CyanLoadFooterView"];
        //    footer.delegete = self;
        return footer;
    }
    return nil;
    
}
////组尾高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (_isMove) {
        return 118;
    }
    return 0.01;
    
}


#pragma mark RefundListDelegate
-(void)tableReloadBy:(NSString *)state andIndexPath:(NSIndexPath *)indexPath{
    if (!state.length) {
        return;
    }
    RefudDesModel *model = _queryResultArr[indexPath.row];
    model.refundStatus = state;
    NSArray *arr = @[indexPath];
    [self.table reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationNone];
}

@end
