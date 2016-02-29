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

@interface ZKPinchViewController () <XWDragCellCollectionViewDataSource, XWDragCellCollectionViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) XWDragCellCollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataSource;

@end

static NSString *const cellID = @"ZKCollectionViewCell";

@implementation ZKPinchViewController

- (void)viewDidLoad
{
    [self setupUI];
}

- (void)setupUI
{
    self.scrollView = ({
        self.scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self.view addSubview:_scrollView];
        _scrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
        _scrollView.minimumZoomScale = 1.f;
        _scrollView.maximumZoomScale = 8.f;
        _scrollView.delegate = self;
//        _scrollView.scrollEnabled = NO;
        _scrollView;
    });
    
    self.collectionView = ({
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 64, 5);
        flowLayout.minimumInteritemSpacing = flowLayout.minimumLineSpacing = 5.f;
        flowLayout.itemSize = CGSizeMake(30.f, 30.f);
        
        self.collectionView = [[XWDragCellCollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([ZKCell class]) bundle:nil] forCellWithReuseIdentifier:cellID];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_scrollView addSubview:_collectionView];
        
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView;
    });
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

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _collectionView;
}

#pragma mark - solve the fuzzy view when zoom scrollView
// 找到需要重新排版的视图
-(NSArray*)findAllViewsToScale:(UIView*)parentView {
    NSMutableArray* views = [[NSMutableArray alloc] init];
    for(id view in parentView.subviews) {
        
        // You will want to check for UITextView here. I only needed labels.
        if([view isKindOfClass:[UILabel class]]) {
            [views addObject:view];
        } else if ([view respondsToSelector:@selector(subviews)]) {
            [views addObjectsFromArray:[self findAllViewsToScale:view]];
        }
    }
    return views;
}

// 根据scale排版在缩放完毕时
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    CGFloat contentScale = scale * [UIScreen mainScreen].scale; // Handle retina
    
    NSArray* labels = [self findAllViewsToScale:self.collectionView];
    for(UIView* view in labels) {
        view.contentScaleFactor = contentScale;
    }
}

@end
