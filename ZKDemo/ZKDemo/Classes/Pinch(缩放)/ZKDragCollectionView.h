//
//  ZKDragCollectionView.h
//  ZKDemo
//
//  Created by ZK on 16/5/27.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZKDragCollectionView;

@protocol ZKDragCollectionViewDataSource <UICollectionViewDataSource>
@required
/** 向dragCollectionView出入外界原始的数据源 */
- (NSArray *)dragCollectionViewOriginalDataSource:(ZKDragCollectionView *)dragCollectionView;
@end

@protocol ZKDragCollectionViewDelegate <UICollectionViewDelegate>
@required
/** 移动后, 将排列后的数据源传给外部 */
- (void)dragCollectionView:(ZKDragCollectionView *)dragCollectionView newDataSourceAfterMove:(NSArray *)newDataSource;
@end

@interface ZKDragCollectionView : UICollectionView
@property (nonatomic, weak) id <ZKDragCollectionViewDataSource> dataSource;
@property (nonatomic, weak) id <ZKDragCollectionViewDelegate>   delegate;

@property (nonatomic, assign) NSTimeInterval minPressDuration;
@property (nonatomic, assign) BOOL           edgeScrollEnable;
@property (nonatomic, assign) BOOL           shakeWhenMoving;
@property (nonatomic, assign) BOOL           longPressEnable;
@end
