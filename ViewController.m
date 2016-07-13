//
//  ViewController.m
//  KBFaceDemo
//
//  Created by 韩金波 on 16/5/30.
//  Copyright © 2016年 Psylife. All rights reserved.
//

#import "ViewController.h"
#import "KBChatBar.h"
#import "KBChatFaceView.h"
#import "KBFaceManager.h"
@interface ViewController ()<KBChatBarDelegate>
@property(nonatomic,strong)UILabel * label;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 200)];
    [self.view addSubview:self.label];
    self.label.numberOfLines = 0;
    // Do any additional setup after loading the view, typically from a nib.
    KBChatBar *chatBar = [[KBChatBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-kMinHeight, self.view.frame.size.width, kMinHeight)];
    chatBar.superViewHeight = self.view.frame.size.height;
    chatBar.delegate = self;
    [self.view addSubview:chatBar];
    
}
-(void)chatBar:(KBChatBar *)chatBar sendMessage:(NSString *)message
{
    chatBar.frame= CGRectMake(0, self.view.frame.size.height-kMinHeight, self.view.frame.size.width, kMinHeight);
//    [chatBar endInputing];
   self.label.attributedText = [KBFaceManager emotionStrWithString:message];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
