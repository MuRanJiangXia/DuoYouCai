//
//  QueryWXOrderViewController.m
//  CloudTiger
//
//  Created by cyan on 16/9/13.
//  Copyright © 2016年 cyan. All rights reserved.
//

#import "QueryWXOrderViewController.h"
#import "QueryWXModel.h"
#import "SBJSON.h"
#import "WXOrderCell.h"
#import "SYQRCodeViewController.h"


@interface QueryWXOrderViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    
    UIButton *queryBtn;
    QueryWXModel *_wxModel;
    UIView *resultView;
    UITextField *_orderTextField;
    NSArray *_titleArr;
    NSArray *_contextArr;

}
@property(nonatomic,strong)UITableView *table;

@end

@implementation QueryWXOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"微信订单";
    self.view.backgroundColor = PaleColor;
    [self createUI];
    
    [self.view addSubview:self.table];
    self.table.hidden = YES;
    _titleArr = @[@"订单号",@"交易类型",@"交易金额",@"交易币种",@"交易时间",@"交易状态"];
    

    

}
#pragma mark --- table
-(UITableView *)table{
    if (!_table) {

        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, queryBtn.bottom + 10, MainScreenWidth, MainScreenHeight - 64 - queryBtn.bottom -10 ) style:UITableViewStylePlain];
        
        [_table registerClass:[WXOrderCell class] forCellReuseIdentifier:@"WXOrderCell"];
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

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _titleArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WXOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXOrderCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.firstLab.text = _titleArr[indexPath.row];
    NSString *context = [_wxModel displayCurrentModlePropertyBy:_contextArr[indexPath.row]];
    
    if ([_titleArr[indexPath.row] isEqualToString:@"交易金额"]) {
        
        NSString *money =  [CyTools  folatByStr:context];
        cell.contLab.text = money ;
        
    }else{
        cell.contLab.text = [NSString stringWithFormat:@"%@",context] ;
        
        
    }
    return cell;
    
    
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
    
}

-(void)createUI{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 10, MainScreenWidth, 60)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
//     CGFloat width =   [CyTools getWidthWithContent:@"订单号" height:60 font:14];
//    NSLog(@"width :%f",width);
    UILabel *label  = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 14 *3 +1, 60)];
//    label.backgroundColor = [UIColor yellowColor];
    label.text = @"订单号";
    label.textColor = GrayColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
    [view addSubview:label];
    
    
    _orderTextField  = [[UITextField alloc]initWithFrame:CGRectMake(label.right + 10, label.top, MainScreenWidth - label.right-10 -15-60 -5, 60)];
    _orderTextField.placeholder = @"订单号";
//    _orderTextField.backgroundColor = [UIColor cyanColor];
    _orderTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _orderTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _orderTextField.textAlignment= NSTextAlignmentRight;
    _orderTextField.delegate = self;
    [view addSubview:_orderTextField];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(MainScreenWidth - 15 -40 , 10, 40, 40);
//    button.backgroundColor = [UIColor redColor];
    
    [button setBackgroundImage:[UIImage imageNamed:@"code_order_btn"] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(codeAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    queryBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    queryBtn.frame = CGRectMake(15, view.bottom + 10, MainScreenWidth -30, 40);
    queryBtn.backgroundColor = BlueColor;
    [queryBtn setTitle:@"查询" forState:UIControlStateNormal];
    [queryBtn addTarget:self action:@selector(WXOrderAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:queryBtn];

    queryBtn.layer.cornerRadius = 5;
    queryBtn.layer.masksToBounds = YES;
    
}

#pragma mark codeAction

-(void)codeAction:(UIButton *)btn{
    //扫描二维码
    SYQRCodeViewController *qrcodevc = [[SYQRCodeViewController alloc] init];
    
    
    qrcodevc.SYQRCodeSuncessBlock = ^(SYQRCodeViewController *aqrvc,NSString *qrString){
        NSLog(@"扫码成功");
        
        NSLog(@"qrString :%@",qrString);
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        _orderTextField.text = qrString;
        
        [self postWX];
        [aqrvc dismissViewControllerAnimated:YES completion:nil];
        
        
    };
    qrcodevc.SYQRCodeFailBlock = ^(SYQRCodeViewController *aqrvc){
        NSLog(@"扫码失败");
        [aqrvc dismissViewControllerAnimated:YES completion:nil];
    };
    qrcodevc.SYQRCodeCancleBlock = ^(SYQRCodeViewController *aqrvc){
        
        NSLog(@"扫码取消");
        
        [aqrvc dismissViewControllerAnimated:YES completion:nil];
        
    };
    [self presentViewController:qrcodevc animated:YES completion:nil];
    
}

-(void)WXOrderAction:(UIButton *)btn{
        [self postWX];
    
}

-(void)postWX{
    
    [_orderTextField resignFirstResponder];
    
    if (!_orderTextField.text.length) {
        [self alterWith:@"输入为空"];
        return;
    }
    [self showSVPByStatus:@"加载中..."];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //申明请求的数据是json类型
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    //    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer =  [AFJSONResponseSerializer serializer];
    //设置请求头 压缩
    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [manager.requestSerializer setTimeoutInterval:15];
    
    CyanManager *cyManager = [CyanManager shareSingleTon];
    
    NSString *sysNo = cyManager.sysNO;
    
    NSString *orderNum = _orderTextField.text ;
//  133268090120161024142847329
    NSDictionary *parameters = @{
                                 @"systemUserSysNo":sysNo,
                                 @"out_trade_no":orderNum
                            
                                 };
    NSString *url = [BaseUrl stringByAppendingString:QueryWXOrderUrl];
//    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    
//    NSString *json = [writer stringWithObject:parameters];
//    20160909150725011992698 支付宝
//    133268090120160913141427457 微信
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        //        NSLog(@"uploadProgress :%@",uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self dismissSVP];
        NSLog(@"responseObject :%@",responseObject);
//        NSInteger code = [responseObject[@"Code"] integerValue];
        
        NSString *Description =[NSString stringWithFormat:@"%@",responseObject[@"Description"]] ;
//    2016-10-18 11:22:36
//         "Description": "ORDERNOTEXIST",
        if (![Description isEqualToString:@"ORDERNOTEXIST"]) {
            NSDictionary *data = responseObject[@"Data"];
            NSDictionary *WxPayData = data[@"WxPayData"];
            NSDictionary *m_values = WxPayData[@"m_values"];
            if (NotNilAndNull(m_values)) {
                
                _wxModel = [[QueryWXModel alloc]init];
                [_wxModel setValuesForKeysWithDictionary:m_values];
                
                if (IsNilOrNull(_wxModel.total_fee ) ) {//
                    return ;
                }
                
                   _table.hidden = NO;
                /**时间截取，，，，，*/
                if (IsNilOrNull(_wxModel.time_end) ) {
                    _wxModel.time_end = @"空";
                }else{
                    if (_wxModel.time_end.length < 14) {
                        _wxModel.time_end = @"空";
                    }else{
                        NSMutableString *muString =[[NSMutableString alloc]initWithString:_wxModel.time_end];
                        [muString insertString:@"-" atIndex:4];
                        [muString insertString:@"-" atIndex:6+1];
                        [muString insertString:@" " atIndex:8 +2];
                        [muString insertString:@":" atIndex:10 +3];
                        [muString insertString:@":" atIndex:12 +4];
                        
                        _wxModel.time_end = [muString copy];
                    }
                
                }
           
                NSLog(@"out_trade_no :%@",_wxModel.out_trade_no);
                //微信 支付宝 判断一下
                _wxModel.pay_Type = @"微信";
//                _wxModel.fee_type = @"人民币";
                NSArray *statusArr = @[@"SUCCESS",@"REFUND",@"NOTPAY",@"CLOSED",@"REVOKED",@"USERPAYING",@"PAYERROR"];
                NSInteger index = [statusArr indexOfObject:_wxModel.trade_state];
                NSLog(@"index :%ld",index);
                switch (index) {
                    case 0:
                        _wxModel.trade_state = @"支付成功";
                        break;
                    case 1:
                        _wxModel.trade_state = @"转入退款";
                        break;
                    case 2:
                        _wxModel.trade_state = @"未支付";
                        break;
                    case 3:
                        _wxModel.trade_state = @"已关闭";
                        break;
                    case 4:
                        _wxModel.trade_state = @"已撤销（刷卡支付）";
                        break;
                    case 5:
                        _wxModel.trade_state = @"用户支付中";
                        break;
                    case 6:
                        _wxModel.trade_state = @"支付失败";
                        break;
                }
                _contextArr  = [_wxModel allPropertyNames];
                
                [self.table reloadData];
        }else{
            
                _table.hidden = YES;
                
                NSLog(@"m_values is NUll");
                [MessageView showMessage:@"查无数据"];
              }

        }else {
            [MessageView showMessage:@"查无数据"];
//            [self showSVPByStatus:@"查无数据"];
//            [SVProgressHUD showInfoWithStatus:@"查无数据"];
            //            [SVProgressHUD showInfoWithStatus:@"查无数据"];

            NSLog(@"请求失败");
            _table.hidden = YES;

 
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self dismissSVP];
        _table.hidden = YES;
        IsNilOrNull(error.userInfo[@"NSLocalizedDescription"])?   [MessageView showMessage:@"网络错误"]:   [MessageView showMessage:error.userInfo[@"NSLocalizedDescription"]];
        

        NSLog(@"error :%@",error);
    }];
 
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}


@end
