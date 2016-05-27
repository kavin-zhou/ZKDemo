//
//  ZKDragCollectionView.m
//  ZKDemo
//
//  Created by ZK on 16/5/27.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKDragCollectionView.h"

#define AngelToRandian(x)  ((x)/180.0*M_PI)
#define TopInset           64.f

typedef NS_ENUM(NSUInteger, USPosterCollectionViewScrollDirection) {
    USPosterCollectionViewScrollDirectionNone = 0,
    USPosterCollectionViewScrollDirectionUp,
    USPosterCollectionViewScrollDirectionDown
};

@interface ZKDragCollectionView ()
@property (nonatomic, assign) CGFloat       shakeLevel;
@property (nonatomic, strong) NSIndexPath   *originalIndexPath;
@property (nonatomic, strong) NSIndexPath   *moveIndexPath;
@property (nonatomic, strong) UIView          *tempMoveCell;
@property (nonatomic, weak) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) CADisplayLink *edgeTimer;
@property (nonatomic, assign) CGPoint       lastPoint;
@property (nonatomic, assign) USPosterCollectionViewScrollDirection scrollDirection;
@end

static NSTimeInterval const  kAnimationDuration = 0.25;
static CGFloat const         speed              = 4.f;

@implementation ZKDragCollectionView
@dynamic dataSource, delegate;

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self initializeProperty];
        [self addGesture];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeProperty];
        [self addGesture];
    }
    
    return self;
}

- (void)initializeProperty
{
    _minPressDuration = 0.8;
    _edgeScrollEnable = YES;
    _shakeWhenMoving = NO;
    _shakeLevel = 4.0f;
    _longPressEnable = YES;
}

#pragma mark - 长按手势

/**
 *  添加一个自定义的滑动手势
 */
- (void)addGesture
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _longPressGesture = longPress;
    longPress.minimumPressDuration = _minPressDuration;
    [self addGestureRecognizer:longPress];
}

/**
 *  监听手势的改变
 */
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGesture
{
    if (!_longPressEnable) {
        return;
    }
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        [self gestureBegan:longPressGesture];
    }
    if (longPressGesture.state == UIGestureRecognizerStateChanged) {
        [self gestureChange:longPressGesture];
    }
    if (longPressGesture.state == UIGestureRecognizerStateCancelled ||
        longPressGesture.state == UIGestureRecognizerStateEnded){
        [self gestureEndOrCancle:longPressGesture];
    }
}

/**
 *  手势开始
 */
- (void)gestureBegan:(UILongPressGestureRecognizer *)longPressGesture
{
    //获取手指所在的cell
    _originalIndexPath = [self indexPathForItemAtPoint:[longPressGesture locationOfTouch:0 inView:longPressGesture.view]];
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:_originalIndexPath];
    _tempMoveCell = [self customSnapshotFromView:cell];
    [self addSubview:_tempMoveCell];
    
    cell.hidden = YES;
    CGPoint center = _tempMoveCell.center;
    [UIView animateWithDuration:kAnimationDuration*0.5 animations:^{
        _tempMoveCell.transform = CGAffineTransformMakeScale(1.2, 1.2);
        _tempMoveCell.alpha = 0.98;
        _tempMoveCell.center = center;
    }];
    
    //开启边缘滚动定时器
    [self setupEdgeTimer];
    _lastPoint = [longPressGesture locationOfTouch:0 inView:longPressGesture.view];
    [self shakeAllCell];
}

- (UIView *)customSnapshotFromView:(UIView *)inputView
{
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.center = inputView.center;
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.f;
    snapshot.layer.shadowOffset = CGSizeMake(-3.f, 0.f);
    snapshot.layer.shadowRadius = 5.f;
    snapshot.layer.shadowOpacity = 0.6;
    
    return snapshot;
}

/**
 *  手势拖动
 */
- (void)gestureChange:(UILongPressGestureRecognizer *)longPressGesture
{
    CGFloat tranX = [longPressGesture locationOfTouch:0 inView:longPressGesture.view].x - _lastPoint.x;
    CGFloat tranY = [longPressGesture locationOfTouch:0 inView:longPressGesture.view].y - _lastPoint.y;
    [self shakeAllCell];
    _tempMoveCell.center = CGPointApplyAffineTransform(_tempMoveCell.center, CGAffineTransformMakeTranslation(tranX, tranY));
    _lastPoint = [longPressGesture locationOfTouch:0 inView:longPressGesture.view];

    [self moveCell];
}

- (void)moveCell
{
    for (UICollectionViewCell *cell in [self visibleCells]) {
        if ([self indexPathForCell:cell] == _originalIndexPath) {
            continue;
        }
        //计算中心距
        CGFloat space = sqrtf(pow(_tempMoveCell.center.x - cell.center.x, 2) + powf(_tempMoveCell.center.y - cell.center.y, 2));
        if (space <= _tempMoveCell.bounds.size.width / 2) {
            _moveIndexPath = [self indexPathForCell:cell];
            //更新数据源
            [self updateDataSource];
            //移动
            [self moveItemAtIndexPath:_originalIndexPath toIndexPath:_moveIndexPath];
            //设置移动后的起始indexPath
            _originalIndexPath = _moveIndexPath;
            break;
        }
    }
}

/**
 *  手势取消或者结束
 */
- (void)gestureEndOrCancle:(UILongPressGestureRecognizer *)longPressGesture
{
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:_originalIndexPath];
    self.userInteractionEnabled = NO;
    [self stopEdgeTimer];
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        _tempMoveCell.center = cell.center;
        _tempMoveCell.transform = CGAffineTransformIdentity;
        cell.alpha = 1;
        
    } completion:^(BOOL finished) {
        [self stopShakeAllCell];
        [_tempMoveCell removeFromSuperview];
        cell.hidden = NO;
        self.userInteractionEnabled = YES;
    }];
}

#pragma mark - setter

- (void)setMinPressDuration:(NSTimeInterval)minPressDuration
{
    _minPressDuration = minPressDuration;
    _longPressGesture.minimumPressDuration = minPressDuration;
}

- (void)setShakeLevel:(CGFloat)shakeLevel
{
    CGFloat level = MAX(1.0f, shakeLevel);
    _shakeLevel = MIN(level, 10.0f);
}
#pragma mark - timer methods

- (void)setupEdgeTimer{
    if (!_edgeTimer && _edgeScrollEnable) {
        _edgeTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(edgeScroll)];
        [_edgeTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopEdgeTimer{
    if (_edgeTimer) {
        [_edgeTimer invalidate];
        _edgeTimer = nil;
    }
}

#pragma mark - 私有方法
/**
 *  更新数据源
 */
- (void)updateDataSource
{
    NSMutableArray *temp = @[].mutableCopy;
    //获取数据源
    if ([self.dataSource respondsToSelector:@selector(dragCollectionViewOriginalDataSource:)]) {
        [temp addObjectsFromArray:[self.dataSource dragCollectionViewOriginalDataSource:self]];
    }
    //判断数据源是单个数组还是数组套数组的多section形式，YES表示数组套数组
    BOOL dataTypeCheck = ([self numberOfSections] != 1 || ([self numberOfSections] == 1 && [temp[0] isKindOfClass:[NSArray class]]));
    if (dataTypeCheck) {
        for (int i = 0; i < temp.count; i ++) {
            [temp replaceObjectAtIndex:i withObject:[temp[i] mutableCopy]];
        }
    }
    if (_moveIndexPath.section == _originalIndexPath.section) {
        NSMutableArray *orignalSection = dataTypeCheck ? temp[_originalIndexPath.section] : temp;
        if (_moveIndexPath.item > _originalIndexPath.item) {
            for (NSUInteger i = _originalIndexPath.item; i < _moveIndexPath.item ; i ++) {
                [orignalSection exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
            }
        }
        else{
            for (NSUInteger i = _originalIndexPath.item; i > _moveIndexPath.item ; i --) {
                [orignalSection exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
            }
        }
    }
    else{
        NSMutableArray *orignalSection = temp[_originalIndexPath.section];
        NSMutableArray *currentSection = temp[_moveIndexPath.section];
        [currentSection insertObject:orignalSection[_originalIndexPath.item] atIndex:_moveIndexPath.item];
        [orignalSection removeObject:orignalSection[_originalIndexPath.item]];
    }
    //将重排好的数据传递给外部
    if ([self.delegate respondsToSelector:@selector(dragCollectionView:newDataSourceAfterMove:)]) {
        [self.delegate dragCollectionView:self newDataSourceAfterMove:temp.copy];
    }
}

- (void)edgeScroll
{
    [self setupScrollDirection];
    UIScrollView *scrollView = (UIScrollView *)self.superview;
    switch (_scrollDirection) {
        case USPosterCollectionViewScrollDirectionDown:{
             [UIView animateWithDuration:.5
                                   delay:0
                                 options:UIViewAnimationOptionCurveEaseInOut
                              animations:^{
                 [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x,
                                                          scrollView.contentOffset.y + speed)];
                 _tempMoveCell.center = CGPointMake(_tempMoveCell.center.x,
                                                    _tempMoveCell.center.y + speed);
                 _lastPoint.y += speed;
                 [self moveCell];
             } completion:nil];
        }
            break;
        case USPosterCollectionViewScrollDirectionUp:{
            [UIView animateWithDuration:.5
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x,
                                                         scrollView.contentOffset.y - speed)];
                _tempMoveCell.center = CGPointMake(_tempMoveCell.center.x,
                                                   _tempMoveCell.center.y - speed);
                _lastPoint.y -= speed;
                [self moveCell];
            } completion:nil];
        }
            break;
        default:
            break;
    }
}

- (void)shakeAllCell
{
    if (!_shakeWhenMoving) {
        return;
    }
    CAKeyframeAnimation* anim=[CAKeyframeAnimation animation];
    anim.keyPath=@"transform.rotation";
    anim.values=@[ @(AngelToRandian(-_shakeLevel)),
                   @(AngelToRandian(_shakeLevel)),
                   @(AngelToRandian(-_shakeLevel)) ];
    anim.repeatCount=MAXFLOAT;
    anim.duration=0.2;
    NSArray *cells = [self visibleCells];
    for (UICollectionViewCell *cell in cells) {
        /**如果加了shake动画就不用再加了*/
        if (![cell.layer animationForKey:@"shake"]) {
            [cell.layer addAnimation:anim forKey:@"shake"];
        }
    }
    if (![_tempMoveCell.layer animationForKey:@"shake"]) {
        [_tempMoveCell.layer addAnimation:anim forKey:@"shake"];
    }
}

- (void)stopShakeAllCell
{
    if (!_shakeWhenMoving) {
        return;
    }
    NSArray *cells = [self visibleCells];
    for (UICollectionViewCell *cell in cells) {
        [cell.layer removeAllAnimations];
    }
    [_tempMoveCell.layer removeAllAnimations];
}

- (void)setupScrollDirection
{
    _scrollDirection = USPosterCollectionViewScrollDirectionNone;
    UIScrollView *scrollView = (UIScrollView *)self.superview;
    CGRect newRect = [_tempMoveCell.superview convertRect:_tempMoveCell.frame toView:KeyWindow];
    CGFloat cellMaxY = CGRectGetMaxY(newRect);
    
    if (cellMaxY >= ScreenHeight-280 && scrollView.contentOffset.y <= scrollView.contentSize.height-ScreenHeight) {
        _scrollDirection = USPosterCollectionViewScrollDirectionDown;
    }
    if (cellMaxY <= TopInset+_tempMoveCell.frame.size.height && scrollView.contentOffset.y >= 0) {
        _scrollDirection = USPosterCollectionViewScrollDirectionUp;
    }
}

#pragma mark - 重写

/**
 *  重写hitTest事件，判断是否应该相应自己的滑动手势，还是系统的滑动手势
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    _longPressGesture.enabled = [self indexPathForItemAtPoint:point]?YES:NO;
    return [super hitTest:point withEvent:event];
}

@end
