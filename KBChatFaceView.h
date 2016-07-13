//
//  KBChatFaceView.h
//  KBFaceDemo
//
//  Created by 韩金波 on 16/7/12.
//  Copyright © 2016年 Psylife. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KBChatFaceViewDelegate <NSObject>

- (void)faceViewSendFace:(NSString *)faceName;

@end

@interface KBChatFaceView : UIView
@property (assign, nonatomic) id<KBChatFaceViewDelegate> delegate;
@end

@protocol PageFaceCellDelegate <NSObject>

- (void)selectedFaceImageWithFaceID:(NSUInteger)faceID;

@end

@interface PageFaceCell : UICollectionViewCell
@property (nonatomic, assign) NSUInteger columnsPerRow;
@property (nonatomic, copy) NSArray *datas;
@property (nonatomic,assign)id<PageFaceCellDelegate> delegate;
@end