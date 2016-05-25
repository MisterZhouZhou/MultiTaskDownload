//
//  GameWebController.h
//  hnatravel
//
//  Created by cuilidong on 15/8/10.
//  Copyright (c) 2015年 hna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameWebController : UIViewController<UIWebViewDelegate>
{
    UIWebView *webView;
}
@property(nonatomic,strong) NSURL * gameDetialUrl;
@property(nonatomic,strong) NSString * gameTitle;
@end
