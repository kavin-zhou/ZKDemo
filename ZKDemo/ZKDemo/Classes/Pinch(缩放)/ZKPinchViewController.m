//
//  ZKMainViewController.m
//  ZKScrollViewZoomAndDrag
//
//  Created by ZK on 16/2/26.
//  Copyright © 2016年 ZK. All rights reserved.
//

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#import "ZKPinchViewController.h"
#import "ZKCell.h"
#import "ZKModel.h"
#import "XWDragCellCollectionView.h"

@interface ZKPinchViewController () <XWDragCellCollectionViewDataSource, XWDragCellCollectionViewDelegate> {
    CGPoint _finalContentOffset;
}

@property (nonatomic, strong) XWDragCellCollectionView *collectionView;
@property (nonatomic, assign) CGSize finalItemSize;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation ZKPinchViewController

static NSString *const cellID = @"ZKCollectionViewCell";

- (void)viewDidLoad
{
    [self setupCollectionView];
}

- (void)setupCollectionView
{
    self.finalItemSize = CGSizeMake(30.f, 30.f);
    
    self.collectionView = ({
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        flowLayout.itemSize = _finalItemSize;
        
        self.collectionView = [[XWDragCellCollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([ZKCell class]) bundle:nil] forCellWithReuseIdentifier:cellID];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
        _collectionView;
    });
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    for (UIGestureRecognizer *recognizer in  self.collectionView.gestureRecognizers){
        if ([recognizer isKindOfClass:[pinchGestureRecognizer class]]) {
            [recognizer requireGestureRecognizerToFail:pinchGestureRecognizer];   //此处使用是为了确保各缩放手势保持独立，不会混淆
        }
    }
    [self.collectionView addGestureRecognizer:pinchGestureRecognizer];
    
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    UICollectionViewFlowLayout *layout =  (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize =  CGSizeMake(_finalItemSize.width * recognizer.scale, _finalItemSize.height * recognizer.scale);
    [layout invalidateLayout];   //废弃旧布局，更新新布局
    
    UIGestureRecognizerState state = recognizer.state;
    if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        self.finalItemSize = CGSizeMake(layout.itemSize.width, layout.itemSize.height);
    }
}

// <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZKCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.model = self.dataSource[indexPath.row];
    return cell;
}

/** 数据源懒加载 */
- (NSArray *)dataSource
{
    if (!_dataSource) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 200; i ++) {
            ZKModel *model = [[ZKModel alloc] init];
            model.title = [NSString stringWithFormat:@"%d",i];
            [tempArray addObject:model];
        }
        _dataSource = tempArray;
    }
    return _dataSource;
}

// <XWDragCellCollectionViewDataSource>
- (NSArray *)dataSourceArrayOfCollectionView:(XWDragCellCollectionView *)collectionView
{
    return _dataSource;
}

- (void)dragCellCollectionView:(XWDragCellCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray
{
    self.dataSource = newDataArray;
}

@end
