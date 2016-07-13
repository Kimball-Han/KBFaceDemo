//
//  KBChatFaceView.m
//  KBFaceDemo
//
//  Created by 韩金波 on 16/7/12.
//  Copyright © 2016年 Psylife. All rights reserved.
//

#import "KBChatFaceView.h"
#import "KBFaceManager.h"
NSString *const cellId = @"pagecell";
@interface KBChatFaceView ()<UICollectionViewDelegate,UICollectionViewDataSource,PageFaceCellDelegate>
@property(nonatomic,strong) NSMutableArray *dataArray;
@property(assign,nonatomic) NSInteger rows ;
@property(assign,nonatomic) NSInteger columnPerRow;
@property(assign,nonatomic) NSInteger itemsPerPage;
@property(assign,nonatomic) NSInteger pageCount;
@property(strong,nonatomic) UIPageControl *pageControl;

@property (weak,nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIView *bottomView;
@property (weak, nonatomic) UIButton *sendButton;

@property (weak, nonatomic) UIButton *recentButton /**< 显示最近表情的button */;
@property (weak, nonatomic) UIButton *emojiButton /**< 显示emoji表情Button */;
@end

@implementation KBChatFaceView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self confingUI];
    }
    return self;
}

-(void)confingUI
{
    [self addSubview:self.pageControl];
    [self addSubview:self.bottomView];
  
    [self setupEmojiFaces];
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.itemSize = CGSizeMake(self.frame.size.width, self.frame.size.height - 60);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 10, self.frame.size.width, self.frame.size.height - 60) collectionViewLayout:flowLayout];
    [collectionView registerClass:[PageFaceCell class] forCellWithReuseIdentifier:cellId];
  
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.pagingEnabled = YES;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    [self addSubview:collectionView];
    
    self.collectionView = collectionView;
}

/**
 *  初始化最近使用的表情数组
 */
- (void)setupRecentFaces{
    
    self.rows = 2;
    self.columnPerRow = 4;
    self.pageCount = 1;
    self.pageControl.numberOfPages = self.pageCount;
    
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:[KBFaceManager recentFaces]];
    
}

/**
 *  初始化所有的emoji表情数组,添加删除按钮
 */
- (void)setupEmojiFaces{
    
    _rows = 3;
    CGFloat s_w =  [UIScreen mainScreen].bounds.size.width;
    _columnPerRow =  s_w > 320 ? 8 : 7;
    
    
    _itemsPerPage = _rows * _columnPerRow;//每页的表情个数
    
    NSInteger pageItemCount = _itemsPerPage -1;//每页除删除表情的个数
    
    [self.dataArray removeAllObjects];
    self.dataArray = [NSMutableArray array];
    [self.dataArray addObjectsFromArray:[KBFaceManager emojiFaces]];
    
    
    NSMutableArray *allFaces = [NSMutableArray arrayWithArray:[KBFaceManager emojiFaces]];
    _pageCount = [allFaces count] % pageItemCount == 0 ? [allFaces count] / pageItemCount : ([allFaces count] / pageItemCount) + 1;
    self.pageControl.numberOfPages = self.pageCount;
    //循环,给每一页末尾加上一个delete图片,如果是最后一页直接在最后一个加上delete图片
    for (int i = 0; i < self.pageCount; i++) {
        if (self.pageCount - 1 == i) {
            [self.dataArray addObject:@{@"face_id":@"999",@"face_name":@"删除"}];
        }else{
            [self.dataArray insertObject:@{@"face_id":@"999",@"face_name":@"删除"} atIndex:(i + 1) * pageItemCount + i];
        }
    }
    
}
#pragma mark - collectionViewDataScore
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _pageCount;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PageFaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.columnsPerRow = self.columnPerRow;
    if ((indexPath.row +1) * _itemsPerPage >= self.dataArray.count) {
        cell.datas = [self.dataArray subarrayWithRange:NSMakeRange(indexPath.row *_itemsPerPage, self.dataArray.count - indexPath.row * _itemsPerPage)];
    }else{
        cell.datas = [self.dataArray subarrayWithRange:NSMakeRange(indexPath.row *_itemsPerPage, _itemsPerPage)];
    }
    cell.delegate = self;
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  self.pageControl.currentPage=  scrollView.contentOffset.x/self.frame.size.width;
}

#pragma mark - PageFaceCellDelegate
-(void)selectedFaceImageWithFaceID:(NSUInteger)faceID
{
    NSString *faceName = [KBFaceManager faceNameWithFaceID:faceID];
    if (faceID != 999) {
        [KBFaceManager saveRecentFace:@{@"face_id":[NSString stringWithFormat:@"%ld",(unsigned long)faceID],@"face_name":faceName}];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewSendFace:)]) {
        [self.delegate faceViewSendFace:faceName];
    }
}
#pragma mark - getters
- (UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height -60, self.frame.size.width, 20)];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        _pageControl.hidesForSinglePage = YES;
    }
    return _pageControl;
}
- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 40, self.frame.size.width, 40)];
        
        UIImageView *topLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 70, 1.0f)];
        topLine.backgroundColor = [UIColor lightGrayColor];
        [_bottomView addSubview:topLine];
        
        UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 70, 0, 70, 40)];
        sendButton.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:70.0f/255.0f blue:1.0f alpha:1.0f];
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_bottomView addSubview:self.sendButton = sendButton];
        
        
        UIButton *recentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [recentButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_recent_normal"] forState:UIControlStateNormal];
        [recentButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_recent_highlight"] forState:UIControlStateHighlighted];
        [recentButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_recent_highlight"] forState:UIControlStateSelected];
        recentButton.tag = 1000;
        [recentButton addTarget:self action:@selector(changeFaceType:) forControlEvents:UIControlEventTouchUpInside];
        [recentButton sizeToFit];
        [_bottomView addSubview:self.recentButton = recentButton];
        [recentButton setFrame:CGRectMake(0, _bottomView.frame.size.height/2-recentButton.frame.size.height/2, recentButton.frame.size.width, recentButton.frame.size.height)];
        
        UIButton *emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_emoji_normal"] forState:UIControlStateNormal];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_emoji_highlight"] forState:UIControlStateHighlighted];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_emoji_highlight"] forState:UIControlStateSelected];
        emojiButton.tag = 2000;
        [emojiButton addTarget:self action:@selector(changeFaceType:) forControlEvents:UIControlEventTouchUpInside];
        [emojiButton sizeToFit];
        [_bottomView addSubview:self.emojiButton = emojiButton];
        [emojiButton setFrame:CGRectMake(recentButton.frame.size.width, _bottomView.frame.size.height/2-emojiButton.frame.size.height/2, emojiButton.frame.size.width, emojiButton.frame.size.height)];
        emojiButton.selected = YES;
    }
    return _bottomView;
}

#pragma mark - 私有方法
- (void)sendAction:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewSendFace:)]) {
        [self.delegate faceViewSendFace:@"发送"];
    }
}

- (void)changeFaceType:(UIButton *)button{
  
    if (button.tag == 1000) {
        if (!button.selected) {
            UIButton * rBut=[self.bottomView viewWithTag:2000];
            rBut.selected = NO;
            button.selected = YES;
            [self setupRecentFaces];
            [self.collectionView reloadData];
        }
    }else if(button.tag == 2000){
        if (!button.selected) {
            UIButton * rBut=[self.bottomView viewWithTag:1000];
            rBut.selected = NO;
            button.selected = YES;
            [self setupEmojiFaces];
            [self.collectionView reloadData];
        }
    }
}
@end

#pragma mark - PageFaceCell
@interface PageFaceCell ()
@property(nonatomic,strong)NSMutableArray *imageViews;
@end
@implementation PageFaceCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        self.imageViews = [NSMutableArray array];
    }
    return self;
}
- (void)setup {
    
    //判断是否需要重新添加所有的imageView
    if (self.imageViews && self.imageViews.count >= self.datas.count) {
        for (UIImageView *imageView in self.imageViews) {
            NSUInteger index = [self.imageViews indexOfObject:imageView];
            imageView.hidden = index >= self.datas.count;
            if (!imageView.hidden) {
                NSDictionary *faceDict = self.datas[index];
                NSString *faceImageName = [KBFaceManager faceImageNameWithFaceID:[faceDict[kFaceIDKey] integerValue]];
                imageView.tag = [faceDict[kFaceIDKey] integerValue];
                imageView.image = [UIImage imageNamed:faceImageName];
            }
        }
    } else {
        //计算每个item的大小
     
        CGFloat itemWidth = (self.frame.size.width - 40) / self.columnsPerRow;
        NSUInteger currentColumn = 0;
        NSUInteger currentRow = 0;
        for (NSDictionary *faceDict in self.datas) {
            if (currentColumn >= self.columnsPerRow) {
                currentRow ++ ;
                currentColumn = 0;
            }
            //计算每一个图片的起始X位置 10(左边距) + 第几列*itemWidth + 第几页*一页的宽度
            CGFloat startX = 20 + currentColumn * itemWidth;
            //计算每一个图片的起始Y位置  第几行*每行高度
            CGFloat startY = currentRow * itemWidth;
            if (startY+itemWidth >self.frame.size.height) {
                startY -=(startY+itemWidth-self.frame.size.height);
            }
            UIImageView *imageView = [self faceImageViewWithID:faceDict[kFaceIDKey]];
            [imageView setFrame:CGRectMake(startX, startY, itemWidth, itemWidth)];
            [self addSubview:imageView];
            [self.imageViews addObject:imageView];
            currentColumn ++ ;
        }
    }
}


-(void)setDatas:(NSArray *)datas
{
    _datas = datas;
    [self setup];
}

- (void)setColumnsPerRow:(NSUInteger)columnsPerRow {
    if (_columnsPerRow != columnsPerRow) {
        _columnsPerRow = columnsPerRow;
        [self.imageViews removeAllObjects];
        for (UIView *subView in self.subviews) {
            [subView removeFromSuperview];
        }
    }
}

- (UIImageView *)faceImageViewWithID:(NSString *)faceID{
    
    NSString *faceImageName = [KBFaceManager faceImageNameWithFaceID:[faceID integerValue]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:faceImageName]];
    imageView.userInteractionEnabled = YES;
    imageView.tag = [faceID integerValue];
    imageView.contentMode = UIViewContentModeCenter;
    
    //添加图片的点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [imageView addGestureRecognizer:tap];
    
    return imageView;
}

#pragma mark - Response Methods

- (void)handleTap:(UITapGestureRecognizer *)tap {
  
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedFaceImageWithFaceID:)]) {
        [self.delegate selectedFaceImageWithFaceID:tap.view.tag];
    }
}


@end
