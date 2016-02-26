//
//  ZKCell.m
//  ZKDemo
//
//  Created by ZK on 16/2/26.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKCell.h"
#import "ZKModel.h"

@interface ZKCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation ZKCell

- (void)setModel:(ZKModel *)model
{
    _model = model;
    self.titleLabel.text = model.title;
}

@end
