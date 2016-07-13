//
//  KBChatBar.h
//  KBFaceDemo
//
//  Created by 韩金波 on 16/7/11.
//  Copyright © 2016年 Psylife. All rights reserved.
//
#define kMaxHeight 60.0f
#define kMinHeight 45.0f
#define kFunctionViewHeight 210.0f


#import <UIKit/UIKit.h>

@class KBChatBar;
@protocol KBChatBarDelegate <NSObject>

@optional
/**
 *  chatBarFrame改变回调
 *
 *  @param chatBar
 */
- (void)chatBarFrameDidChange:(KBChatBar *)chatBar frame:(CGRect)frame;
/**
 *  发送普通的文字信息,可能带有表情
 *
 *  @param chatBar
 *  @param message 需要发送的文字信息
 */
- (void)chatBar:(KBChatBar *)chatBar sendMessage:(NSString *)message;

@end


@interface KBChatBar : UIView
@property (assign,nonatomic)CGFloat superViewHeight;
@property (assign,nonatomic) id<KBChatBarDelegate> delegate;

-(void)startInputing;

-(void)endInputing;
@end
