//
//  ZKMainViewController.m
//  ZKScrollViewZoomAndDrag
//
//  Created by ZK on 16/2/26.
//  Copyright © 2016年 ZK. All rights reserved.
//
#define ItemNumPerRow (int)floorf((ScreenWidth-margin)/(itemW+margin))
#define contentH (ceil((float)itemTotalNum/ItemNumPerRow)*(itemW+margin)+margin)

#import "ZKPinchViewController.h"
#import "ZKCell.h"
#import "ZKModel.h"
#import "XWDragCellCollectionView.h"

@interface ZKPinchViewController () <XWDragCellCollectionViewDataSource, XWDragCellCollectionViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) XWDragCellCollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, assign) BOOL allowedPinch;  //是否允许缩放

@end

static NSString *const cellID = @"ZKCollectionViewCell";
static NSInteger const itemTotalNum = 150;
static CGFloat const margin = 5.f;
static CGFloat const itemW = 30.f;

@implementation ZKPinchViewController

- (void)viewDidLoad
{
    self.allowedPinch = YES;
    [self p_setupUI];
}

- (void)p_setupUI
{
    self.scrollView = ({
        self.scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self.view addSubview:_scrollView];
        _scrollView.backgroundColor = [UIColor lightGrayColor];
        _scrollView.contentSize = CGSizeMake(ScreenWidth, contentH);
        _scrollView.minimumZoomScale = 1.f;
        _scrollView.maximumZoomScale = 8.f;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.alwaysBounceHorizontal = self.allowedPinch?YES:NO;
        _scrollView.alwaysBounceVertical = self.allowedPinch?YES:NO;
        _scrollView.bounces = self.allowedPinch?YES:NO;
        _scrollView;
    });
    
    self.collectionView = ({
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumInteritemSpacing = flowLayout.minimumLineSpacing = margin;
        flowLayout.itemSize = CGSizeMake(itemW, itemW);
        
        self.collectionView = [[XWDragCellCollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, contentH) collectionViewLayout:flowLayout];
        _collectionView.contentInset = UIEdgeInsetsMake(margin, margin, 64, margin);
        _collectionView.backgroundColor = [UIColor clearColor];
//        _collectionView.shakeWhenMoveing = NO; //关闭抖动动画
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([ZKCell class]) bundle:nil] forCellWithReuseIdentifier:cellID];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_scrollView addSubview:_collectionView];
        _collectionView.scrollEnabled = NO;
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
        for (int i = 0; i < itemTotalNum; i ++) {
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

// <UIScrollViewDelegate>
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.allowedPinch ? _collectionView : nil;
}

#pragma mark - solve the fuzzy view when zoom scrollView
// 根据scale排版在缩放完毕时
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    CGFloat contentScale = scale * [UIScreen mainScreen].scale; // Handle retina
    
    NSArray* labels = [self p_findAllViewsToScale:self.collectionView];
    for(UIView* view in labels) {
        view.contentScaleFactor = contentScale;
    }
}
// 找到需要重新排版的视图
-(NSArray*)p_findAllViewsToScale:(UIView*)parentView {
    NSMutableArray* views = [[NSMutableArray alloc] init];
    for(id view in parentView.subviews) {
        
        // 有textView的话也要判断
        if([view isKindOfClass:[UILabel class]]) {
            [views addObject:view];
        } else if ([view respondsToSelector:@selector(subviews)]) {
            [views addObjectsFromArray:[self p_findAllViewsToScale:view]];
        }
    }
    return views;
}

@end
