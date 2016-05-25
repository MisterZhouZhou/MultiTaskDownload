//
//  GameWebController.m
//  hnatravel
//
//  Created by cuilidong on 15/8/10.
//  Copyright (c) 2015年 hna. All rights reserved.
//

#import "GameWebController.h"

#define kScreen_Height [UIScreen mainScreen].bounds.size.height
#define kScreen_Width [UIScreen mainScreen].bounds.size.width
@interface GameWebController ()
@end

@implementation GameWebController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.title = self.gameTitle;
    self.view.backgroundColor = [UIColor grayColor];
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0, kScreen_Width, kScreen_Height)];

    webView.delegate = self;
    webView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:webView];
    [webView loadRequest:[NSURLRequest requestWithURL:self.gameDetialUrl]];

    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;

}


#pragma mark-代理事件
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType

{
       return true;
    
}



-(void)webViewDidFinishLoad:(UIWebView *)myWebView
{
    [myWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //[hud hide:YES afterDelay:3];
   // [self.view endLoading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
