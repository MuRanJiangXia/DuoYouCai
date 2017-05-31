//
//  StaffRateSumModel.h
//  CloudTiger
//
//  Created by cyan on 16/12/5.
//  Copyright © 2016年 cyan. All rights reserved.
//

#import "BaseModel.h"

@interface StaffRateSumModel : BaseModel
//    员工名称	交易金额	实际交易金额	交易币种	交易笔数	商户费率	返佣


/**真实姓名*/
@property(nonatomic,copy)NSString *CustomerName;


/**2017，5，10  Cash_fee 修改为 Total_fee*/

/**交易金额*/
@property(nonatomic,copy)NSString *Total_fee;

/**实际金额*/
@property(nonatomic,copy)NSString *Fee;

/**交易币种*/
@property(nonatomic,copy)NSString *Cash_fee_type;

/**交易笔数*/
@property(nonatomic,copy)NSString *Tradecount;

/**商户费率*/
@property(nonatomic,copy)NSString *Rate;

/**返佣*/
@property(nonatomic,copy)NSString *Rate_fee;

@end
