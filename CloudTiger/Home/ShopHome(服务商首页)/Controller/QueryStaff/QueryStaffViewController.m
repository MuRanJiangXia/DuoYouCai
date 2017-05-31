//
//  QueryStaffViewController.m
//  CloudTiger
//
//  Created by cyan on 16/9/22.
//  Copyright © 2016年 cyan. All rights reserved.
//

#import "QueryStaffViewController.h"
#import "QueryCell.h"
#import "QueryCell2.h"
#import "QueryCell3.h"
#import "QueryHeaderView.h"
#import "QueryFooterView.h"
#import "QueryModel.h"
#import "SBJsonWriter.h"
#import "StaffListViewController.h"
@interface QueryStaffViewController ()<UITableViewDelegate,UITableViewDataSource,QueryCellDelegate,QueryFooterDelegate>{
    
    NSArray *_queryArr;
    NSMutableArray *_cellArr;

}
@property(nonatomic,strong)UITableView *table;

@end

@implementation QueryStaffViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"员工查询";
    self.view.backgroundColor = PaleColor;
    [self.view addSubview:self.table];
   /**底部返回首页按钮*/
    [self homeBtnView];
    [self loadData];
}

-(void)loadData{
    
    _queryArr  = @[         @{@"list":@[@{@"LoginName":@"登录名"},
                                        @{@"PhoneNumber":@"电话"}
                                        
                                        ]
                              }
                            
                            ];
    
    _cellArr = [NSMutableArray new];
    for (NSInteger index =0 ; index<_queryArr.count; index ++) {
        
        QueryModel *queryModel = [[QueryModel alloc]initWithShopDict:_queryArr[index]];
        
        [_cellArr addObject:queryModel];
    }
    
    [self.table reloadData];
    
}

#pragma mark --- table
-(UITableView *)table{
    if (!_table) {
        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, MainScreenWidth, MainScreenHeight -44) style:UITableViewStyleGrouped];
        
        [_table registerClass:[QueryCell class] forCellReuseIdentifier:@"QueryCell"];
        [_table registerClass:[QueryCell2 class] forCellReuseIdentifier:@"QueryCell2"];
        [_table registerClass:[QueryCell3 class] forCellReuseIdentifier:@"QueryCell3"];
        
        //
        [_table registerClass:[QueryHeaderView class] forHeaderFooterViewReuseIdentifier:@"QueryHeaderView"];
        [_table registerClass:[QueryFooterView class] forHeaderFooterViewReuseIdentifier:@"QueryFooterView"];
        //        [_table registerClass:[SubOrderHeaderView class] forHeaderFooterViewReuseIdentifier:@"SubOrderHeaderView"];
        
        _table.delegate = self;
        _table.dataSource = self;
        _table.backgroundColor = PaleColor;
        //去掉头部留白
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.001)];
        view.backgroundColor = [UIColor redColor];
        _table.tableHeaderView = view;
        //去掉边线
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _table;
}


#pragma  mark UITableViewDataSource
//组个数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _cellArr.count;
}
//单元格个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    QueryModel *queryModel = _cellArr[section];
    return queryModel.headCellArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    QueryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QueryCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    QueryModel *queryModel = _cellArr[indexPath.section];
    cell.indexPath = indexPath;
    cell.queryCellmodel = queryModel.headCellArray [indexPath.row];
    cell.delegete = self;
    //        cell.isLockText = YES;
    return cell;
    
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

//组尾
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == _cellArr.count -1) {
        QueryFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"QueryFooterView"];
        footer.delegete = self;
        return footer;
    }else{
        
        return nil;
    }
    
    
}

//组头
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    
    QueryHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"QueryHeaderView"];
    return header;
    
}
//单元格高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
    
}
//组头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    
    return 10;
    
}
//组尾高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (section == _cellArr.count -1) {
        return 60;
    }else{
        
        return 0.0001;
    }
}
#pragma mark QueryCellDelegate
-(void)messWithText:(NSString *)text ByIndexPath:(NSIndexPath *)indexPath{
    QueryModel *queryModel =   _cellArr[indexPath.section];
    QueryCellModel *cellModel = queryModel.headCellArray[indexPath.row];
    cellModel.cellText = text;
    [self.table reloadData];
    NSLog(@"text :%@ section :%ld",text,indexPath.section);
    
}
-(void)messWithText2:(NSString *)text ByIndexPath:(NSIndexPath *)indexPath{
    QueryModel *queryModel =   _cellArr[indexPath.section];
    QueryCellModel *cellModel = queryModel.headCellArray[indexPath.row];
    cellModel.cellText = text;
    [self.table reloadData];
    NSLog(@"text :%@ section :%ld",text,indexPath.section);
    
}
-(void)messWithText3:(NSString *)text ByIndexPath:(NSIndexPath *)indexPath{
    QueryModel *queryModel =   _cellArr[indexPath.section];
    QueryCellModel *cellModel = queryModel.headCellArray[indexPath.row];
    cellModel.cellText = text;
    [self.table reloadData];
    NSLog(@"text :%@ section :%ld",text,indexPath.section);
    
}
#pragma mark QueryFooterDelegate
-(void)queryAction{
    /**
     必须 把键盘收起来不然，， 会少穿字段
     */
    [_table endEditing:YES];
    //
    /*
    LoginName  商户名称
    PhoneNumber  商户用户名

    CustomerServiceSysNo  服务商,商户主键
     
     PagingInfo PageNumber（当前页数索引
     PageSize（每页行数
     */
    NSMutableDictionary *parameter = [NSMutableDictionary new];
    
    for (NSInteger index = 0; index < _cellArr.count; index++) {
        QueryModel *queryModel = _cellArr[index];
        for (NSInteger index2  = 0; index2 <queryModel.headCellArray.count ; index2++) {
            QueryCellModel *cellModel = queryModel.headCellArray [index2];
            [parameter setObject:cellModel.cellText forKey:cellModel.titleKey];
        }
        
    }
    
    CyanManager  *maneger = [CyanManager shareSingleTon];
    NSLog(@"sysNO : %@",maneger.sysNO);
    StaffListViewController *query = [StaffListViewController  new];
    query.paramters = parameter;
    query.staffState = self.staffState;
    [self.navigationController pushViewController:query animated:YES];
    
    
    
}


@end
