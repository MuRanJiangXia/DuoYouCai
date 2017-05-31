//
//  ShopHomeViewController.m
//  CloudTiger
//
//  Created by cyan on 16/9/7.
//  Copyright © 2016年 cyan. All rights reserved.
//

#import "ShopHomeViewController.h"
#import "ShopHomeNavView.h"
#import "ShopHomeCell.h"
#import "QueryStaffViewController.h"
#import "ShopQueryViewController.h"
#import "QueryViewController.h"
#import "QuerySumModel.h"
#import "ShopCountViewController.h"
#import "StaffSummaryViewController.h"
#import "QueryRateViewController.h"
#import "ShopPowerViewController.h"
#import "StaffPowerViewController.h"
#import "LoginViewController.h"
#import "ShopRefundViewController.h"


@interface ShopHomeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>{
    
    
    NSMutableArray *_shopCellArr;
    CyanManager *_cyanManager;
    
    QuerySumModel *_querySumModel;
    NSArray *_powerArr;
}

@property(nonatomic,strong)UICollectionView *shopCollection;
@end


@implementation ShopHomeViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //    self.navigationController.navigationBarHidden = YES;
    
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    //    self.navigationController.navigationBarHidden = NO;
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = PaleColor;
    _cyanManager     = [CyanManager shareSingleTon];
    
    NSLog(@"服务商首页");
    //完成登录
    [CyTools loginSuccess];
    [CyTools isLoginSuccess];
    
    [self.view addSubview:self.shopCollection];
    
    [self initConfigure];
    [self loadData];
    //商户的时候查询权限
    if ([_cyanManager.customersType isEqualToString:@"1"]) {
        /**
         判断 权限是否为空
         如果是空 就加载
         如果不是空 就加载
         */
        NSArray *arr;
        arr = @[CyanStaffList,CyanOrderQuery,CyanStaffCode ,CyanStaffPower,CyanRateOrder,CyanRefundQuery,CyanCount];
        
        NSArray *fiter = (NSArray *)[List objectForKey:UserPowers] ;
        if (fiter.count) {
            [self  reloagUI:fiter By:arr];
        }else{
            
            [self loadShopPower];
        }
        
    }
    
    [self postCountMoney];
    
}
-(void)postCountMoney{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //申明请求的数据是json类型
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    //    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer =  [AFJSONResponseSerializer serializer];
    //设置请求头 压缩
    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [manager.requestSerializer setTimeoutInterval:15];
    
    CyanManager *cyManager = [CyanManager shareSingleTon];
    
    NSString *url = @"" ;
    //    {
    //        "CustomersTopSysNo": "1",
    //        "CustomerName": "",
    //        "Time_Start": "2016-09-27 00:00:00",
    //        "Customer": "",
    //        "PagingInfo": {
    //            "PageNumber": 0,
    //            "PageSize": 10
    //        },
    //        "Pay_Type": "",
    //        "Time_end": "2016-09-27 23:59:59",
    //        "Out_trade_no": ""
    //    }
    NSNumber *number = [NSNumber numberWithInteger:0];
    NSNumber *number2 = @1000;
    NSDictionary *pageDic = @{
                              @"PageNumber":number,
                              @"PageSize":number2
                              };
    
    /**
     获取当地时间  。。。
     */
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval dis = [date timeIntervalSince1970];
    
    NSString *time =  [CyTools getYearAndMonthAndDayByTimeInterval:dis];
    
    NSString *beginTime = [NSString stringWithFormat:@"%@ 00:00:00",time];
    NSString *endTime = [NSString stringWithFormat:@"%@ 23:59:59",time];
    NSMutableDictionary *paramters =[ @{
                                        @"Customer":@"",
                                        @"CustomerName":@"",
                                        @"Out_trade_no":@"",
                                        @"Pay_Type":@"",
                                        @"Time_Start":beginTime,
                                        @"Time_end":endTime
                                        } mutableCopy];
    
    
    [paramters setObject:pageDic forKey:@"PagingInfo"];
    
    //
    if ([cyManager.customersType isEqualToString:@"0"]) {//服务商
        [paramters setObject:cyManager.sysNO forKey:@"CustomersTopSysNo"];
    }else{
        
        [paramters setObject:cyManager.sysNO forKey:@"CustomerSysNo"];
        
    }
    url = [BaseUrl stringByAppendingString:SummaryUrl];
    
    
    
    
    [manager POST:url parameters:paramters progress:^(NSProgress * _Nonnull uploadProgress) {
        ;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"responseObject :%@",responseObject);
        
        NSArray *model = responseObject[@"model"];
        [self endRefreshing];
        
        if (!model.count) {
            NSLog(@"查无数据");
            
        }else{
            //            /**交易金额*/
            //            @property(nonatomic,copy)NSString *Cash_fee;
            //            /**实际交易金额*/
            //            @property(nonatomic,copy)NSString *fee;
            NSInteger fee = 0;
            NSInteger Cash_fee = 0;
            NSInteger Tradecount = 0;
            
            
            for (NSDictionary* dic in model) {
                
                //                *Cash_fee;
                //                *fee;
                //                *Tradecount;
                fee = fee +  [dic[@"fee"] integerValue];
                Cash_fee = Cash_fee +  [dic[@"Total_fee"] integerValue];
                Tradecount = Tradecount +[dic[@"Tradecount"] integerValue];
            }
            _querySumModel  = [[ QuerySumModel alloc]init];
            _querySumModel.fee = [NSString stringWithFormat:@"%ld",fee];
            _querySumModel.Total_fee = [NSString stringWithFormat:@"%ld",Cash_fee];
            
            _querySumModel.Tradecount = [NSString stringWithFormat:@"%ld",Tradecount];
            
            
            [self.shopCollection reloadData];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"error :%@",error);
    }];
    
}

-(void)loginOut{
    LoginViewController *login = [LoginViewController new];
    UIWindow* window =  [UIApplication sharedApplication].keyWindow;
    window.rootViewController = login;
    //    [_cyanManager cleanUserInfo];
    
    /**
     tabbar  需要从新刷新
     */
    CyanManager  *cyManager = [CyanManager shareSingleTon];
    cyManager.isLoadTabar = YES;
    [CyTools loginException];
}
/**
 员工列表  "/Staff/staff_list"
 交易订单查询  "/Order/order_search"
 统计   “count/cyan”  //没有 假的数据
 员工二维码   "/Qrcode/index"
 员工权限分配  "/Permission/permission_assignment"
 费率订单查询   "/OrderFund/orderfund"
 
 */

/**获取商户权限*/
-(void)loadShopPower{
    
    [self showSVPByStatus:@"加载中..."];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //申明请求的数据是json类型
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    //    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer =  [AFJSONResponseSerializer serializer];
    //设置请求头 压缩
    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [manager.requestSerializer setTimeoutInterval:15];
    
    
    
    //    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    //    NSString *json = [writer stringWithObject:self.paramters];
    
#warning 从上一个页面获取
    NSDictionary *parameters = @{
                                 @"CustomerServiceSysNo":_cyanManager.sysNO
                                 
                                 };
    
    //    该商户权限
    NSString *url  =[BaseUrl stringByAppendingString:ShopHavePowerUrl];
    
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        ;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self dismissSVP];
        NSLog(@"responseObject : %@",responseObject);
        
        NSMutableArray *powerArr = [NSMutableArray array];
        NSArray *modelArr = responseObject;
        for (NSInteger index = 0; index < modelArr.count; index ++) {
            
            NSDictionary *dic = modelArr[index];
            NSString *URL = dic[@"URL"];
            [powerArr addObject:URL];
        }
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"(SELF IN %@)",powerArr];
        NSArray *arr2;
        /**
         员工列表  "/Staff/staff_list"
         交易订单查询  "/Order/order_search"
         统计   “count/cyan”  //没有 假的数据
         员工二维码   "/Qrcode/index"
         员工权限分配  "/Permission/permission_assignment"
         费率订单查询   "/OrderFund/orderfund"
         */
        // 员工列表 交易订单查询   员工二维码 员工权限分配  费率订单查询 退款查询 上级费率订单 统计
        arr2 = @[CyanStaffList,CyanOrderQuery,CyanStaffCode ,CyanStaffPower,CyanRateOrder,CyanRefundQuery,CyanCount];
        
        //filter 是最终获取的权限
        NSArray * filter = [arr2 filteredArrayUsingPredicate:filterPredicate];
        
        //        filter = @[@"/OrderFund/orderfund?Top=1"];
        
        [self reloagUI:filter By:arr2];
        /**
         2017,5,3  保存权限不在每次将要初始化的时候加载了
         */
        //保存本地
        [List  setObject:filter forKey:UserPowers];
        
        NSLog(@"filter : %@",filter);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error : %@",error);
#pragma mark 需要跳转登录页
        [self dismissSVP];
        
        [MessageView showMessage:@"获取商户权限失败"];
        [self performSelector:@selector(loginOut) withObject:nil afterDelay:1];
        
    }];
    
}

/**
 根据权限刷新 UI
 
 @param filter 当前用户拥有的权限
 @param arr2 所有权限
 */
-(void)reloagUI:(NSArray *)filter By:(NSArray *)arr2{
    
    //保留 权限
    _cyanManager.powers = filter;
    
    for (NSInteger index = 0; index < _shopCellArr.count ; index ++) {
        NSString *power = arr2[index];
        NSInteger powerIndex = [filter indexOfObject:power];
        if (powerIndex != NSNotFound) {
            StaffModel *staffModel = _shopCellArr[index];
            staffModel.isHave = YES;
        }
        
    }
    //测试 权限为空
    //        filter = @[@"/Business/business"];
    _powerArr = filter;
    
    [self.shopCollection reloadData];
    
}

/**下拉刷新*/
-(void)initConfigure{
    
    [self.shopCollection addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(reloadDATA)];
    [self.shopCollection.header setTitle:@"下拉刷新" forState:MJRefreshHeaderStateIdle];
    
}

-(void)endRefreshing{
    
    
    [self.shopCollection.header endRefreshing];
}
#pragma mark 下拉刷新
-(void)reloadDATA{
    [self postCountMoney];
    NSLog(@"下拉刷新");
}

-(void)loadData{
    
    
    NSLog(@" sysNO:%@,isStaff :%@,customersType :%@",_cyanManager.sysNO,_cyanManager.isStaff,_cyanManager.customersType);
    NSArray *orderDisabledArr;
    NSArray *orderArr ;
    NSArray *orderSelectedArr;
    NSArray *titleArr;
    //    customer_staff_sum_n  shop_assign_n staff_assign_n  shop_rate_order_n
    if ([_cyanManager.customersType isEqualToString:@"0"]) {
        orderArr  = @[@"staff_list_n",@"order_query_n",@"customer_staff_sum_n",@"shop_query_n",@"shop_assign_n",@"staff_assign_n",@"shop_refund_n",@"shop_count_n"];
        orderSelectedArr  = @[@"staff_list_s",@"order_query_s",@"customer_staff_sum_n",@"shop_query_s",@"shop_assign_n",@"staff_assign_n",@"shop_refund_n",@"shop_count_s"];
        titleArr = @[@"员工列表",@"订单查询",@"员工订单汇总",@"商户查询",@"商户权限分配",@"员工权限分配",@"退款查询",@"统计"];
    }else{
        
        orderDisabledArr = @[@"staff_list_d",@"order_query_d",@"shop_code_d",@"staff_assign_d",@"shop_rate_d",@"shop_refund_d",@"shop_count_d"];
        orderArr  = @[@"staff_list_n",@"order_query_n",@"shop_code_n",@"staff_assign_n",@"shop_rate_n",@"shop_refund_n",@"shop_count_n"];
        orderSelectedArr  = @[@"staff_list_s",@"order_query_s",@"shop_code_s",@"staff_assign_n",@"shop_rate_n",@"shop_refund_n",@"shop_count_s"];
        titleArr = @[@"员工列表",@"订单查询",@"员工二维码",@"员工权限分配",@"费率订单",@"退款查询",@"统计"];
        
    }
    
    _shopCellArr = [NSMutableArray new];
    for (NSInteger index = 0; index < orderArr.count; index ++) {
        StaffModel *model = [[StaffModel alloc]init];
        model.btnDisabled = orderDisabledArr[index];
        model.btnNormal = orderArr[index];
        model.btnSelected = orderSelectedArr[index];
        model.title = titleArr[index];
        //服务商所有权限都有
        if ([_cyanManager.customersType isEqualToString:@"0"]) {
            model.isHave = YES;
        }
        
        [_shopCellArr addObject:model];
    }
    
    [self.shopCollection reloadData];
}
#pragma mark -- collection
-(UICollectionView *)shopCollection{
    
    if (!_shopCollection) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumInteritemSpacing=0;
        layout.minimumLineSpacing=0;
        _shopCollection=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, MainScreenWidth, MainScreenHeight)  collectionViewLayout:layout];
        _shopCollection.delegate=self;
        _shopCollection.dataSource=self;
        _shopCollection.showsVerticalScrollIndicator=NO;
        _shopCollection.showsHorizontalScrollIndicator=NO;
        _shopCollection.backgroundColor= PaleColor;
        
#pragma mark -- 注册单元格
        [_shopCollection registerClass:[ShopHomeCell class] forCellWithReuseIdentifier:@"ShopHomeCell"];
        //        [_shopCollection registerClass:[ShoppingCartCell class] forCellWithReuseIdentifier:@"ShoppingCartCell"];
#pragma mark -- 注册头部视图
        [_shopCollection registerClass:[ShopHomeNavView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ShopHomeNavView"];
        
#pragma mark -- 注册尾视图
        //        [_shopCollection registerClass:[ShopFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ShopFooterView"];
    }
    return _shopCollection;
}

#pragma mark UICollectionViewDataSource
//分组
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;//推荐
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _shopCellArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ShopHomeCell  *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ShopHomeCell" forIndexPath:indexPath];
    cell.model = _shopCellArr[indexPath.row];
    return cell;
    
}

//组头
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString: UICollectionElementKindSectionHeader]) {
        ShopHomeNavView * top = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ShopHomeNavView" forIndexPath:indexPath];
        top.querySumModel = _querySumModel;
        return top;
    }else{
        return nil;
    }
    
}
//每组里item的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(MainScreenWidth /3, MainScreenWidth /3);
    
}
//头
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    return CGSizeMake(MainScreenWidth, 200 -35);
}
//尾
//每个section的footer
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    
    return CGSizeMake(0,0);
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //            kOrderShop   = 0,//商户订单查询
    //            kOrderShopUser        =  10,//商户员工订单查询
    //            kOrderCustomer   = 20 ,//服务商订单查询
    //            kOrderCustomerUser = 30//服务商员工订单查询
    
    if ([_cyanManager.customersType isEqualToString:@"0"]) {//服务商
        switch (indexPath.row) {
            case 0:
            {
                QueryStaffViewController *queryStaff = [QueryStaffViewController new];
                queryStaff.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:queryStaff animated:YES];
            }
                break;
            case 1:
            {
                
                QueryViewController *query = [QueryViewController new];
                query.queryOrderState = kOrderCustomer;
                query.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:query animated:YES];
            }
                break;
            case 2:
            {
                StaffSummaryViewController *staffSummary = [StaffSummaryViewController new];
                staffSummary.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:staffSummary animated:YES];
                
            }
                break;
                
            case 3:
            {
                ShopQueryViewController *shopQuery  = [ShopQueryViewController new];
                shopQuery.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:shopQuery animated:YES];
            }
                break;
                
                
            case 4:
            {
                ShopPowerViewController *shopPower  = [ShopPowerViewController new];
                shopPower.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:shopPower animated:YES];
            }
                break;
            case 5:
            {
                StaffPowerViewController *staffPower  = [StaffPowerViewController new];
                staffPower.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:staffPower animated:YES];
            }
                break;
            case 6:
            {
                
                ShopRefundViewController *shopRefund  = [ShopRefundViewController new];
                shopRefund.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:shopRefund animated:YES];
            }
                break;
            case 7:
            {
                ShopCountViewController *shopCount = [ShopCountViewController new];
                shopCount.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:shopCount animated:YES];
            }
                break;
                
                
            default:
                break;
        }
    }else{
        
        StaffModel *model =  _shopCellArr[indexPath.row];
        if (!model.isHave) {
            //            [self alterWith:@"没有该权限"];
            NSLog(@"没有该权限");
            return;
        }
        
        switch (indexPath.row) {//商户
            case 0:
            {
                QueryStaffViewController *queryStaff = [QueryStaffViewController new];
                queryStaff.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:queryStaff animated:YES];
            }
                break;
            case 1:
            {
                QueryViewController *query = [QueryViewController new];
                query.hidesBottomBarWhenPushed = YES;
                query.queryOrderState = kOrderShop;
                
                [self.navigationController pushViewController:query animated:YES];
            }
                break;
                
            case 2://员工二维码 （先进员工查询）
            {
                QueryStaffViewController *queryStaff = [QueryStaffViewController new];
                queryStaff.hidesBottomBarWhenPushed = YES;
                queryStaff.staffState = kStaffCode;
                [self.navigationController pushViewController:queryStaff animated:YES];
            }
                break;
                
            case 3://员工权限分配
            {
                StaffPowerViewController *staffPower  = [StaffPowerViewController new];
                staffPower.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:staffPower animated:YES];
                
            }
                break;
                
            case 4://费率订单
            {
                NSLog(@"费率订单");
                
                QueryRateViewController *query = [QueryRateViewController new];
                query.hidesBottomBarWhenPushed = YES;
                //                kTopShopRate kOrderShop
                query.queryOrderState = kOrderShop;
                [self.navigationController pushViewController:query animated:YES];
                
            }
                break;
            case 5://退款查询
            {
                NSLog(@"退款查询");
                
                ShopRefundViewController *shopRefund = [ShopRefundViewController new];
                
                shopRefund.hidesBottomBarWhenPushed = YES;
                //                kTopShopRate kOrderShop
                //                shopRefund.queryOrderState = kOrderShop;
                [self.navigationController pushViewController:shopRefund animated:YES];
                
            }
                break;
                
                //            case 6://上级费率查询
                //            {
                //                NSLog(@"上级费率查询");
                //
                //                QueryRateViewController *query = [QueryRateViewController new];
                //                query.hidesBottomBarWhenPushed = YES;
                //                //                kTopShopRate kOrderShop
                //                query.queryOrderState = kTopShopRate;
                //                [self.navigationController pushViewController:query animated:YES];
                //            }
                //                break;
                
                
            case 6:
            {
                ShopCountViewController *shopCount = [ShopCountViewController new];
                shopCount.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:shopCount animated:YES];
            }
                break;
            default:
                break;
        }
        
    }
    
    
}

@end
