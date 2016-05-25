//
//  ViewController.m
//  读取iOS应用中版本号
//
//  Created by rayootech on 16/3/23.
//  Copyright © 2016年 rayootech. All rights reserved.
//

#import "ViewController.h"
#import "SSZipArchive.h"
#import "UIImageView+WebCache.h"
#import "YLImageView.h"
#import "AFNetworking.h"
#import "GameWebController.h"
#import "ZWButton.h"

#define GameAddressUrl @"http://xxx.com"
#define GameUpdateAddressUrl @"http:////xxx.com"
#define k_ProsessWidth (kScreen_Width - 20)

#define  GameType_SLYZ @"slyz"
#define  GameString_SLYZ @"时来运转"
#define  GameType_CDX @"cdx"
#define  GameString_CDX @"猜大小"

@interface ViewController ()
{
    NSString *gType;  //游戏类型，判断是时来运转还是积分时时乐

    //时时乐按钮
     ZWButton*slyzBtn;
    
     ZWButton *cdxBtn;
    
    BOOL slyzIsSel;
    BOOL cdxIsSel;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
//   //必须制定游戏路径
    
    
    //添加游戏类型
    
    [self addGameButton];
}

#pragma mark-添加游戏按钮
-(void)addGameButton{
    //按钮
    ZWButton *btn=[ZWButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(20, 60, 100, 100);
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"时时乐" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor lightGrayColor];
    [btn setImage:[UIImage imageNamed:@"hotLine"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.bgLayer.hidden = YES;
    [self.view addSubview:btn];
    slyzBtn = btn;
    
    ZWButton *btn2=[ZWButton buttonWithType:UIButtonTypeCustom];
    btn2.frame=CGRectMake(CGRectGetMaxX(btn.frame)+20, 60, 100, 100);
    [btn2 addTarget:self action:@selector(btn2Click) forControlEvents:UIControlEventTouchUpInside];
    [btn2 setTitle:@"猜大小" forState:UIControlStateNormal];
    btn2.backgroundColor = [UIColor lightGrayColor];
    [btn2 setImage:[UIImage imageNamed:@"hotLine"] forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn2.bgLayer.hidden = YES;
    [self.view addSubview:btn2];
    cdxBtn= btn2;
    
    //进度目录,如果没有现在完成设置初始化进度
    NSString *tempFile =[NSString stringWithFormat:@"%@Temp.txt",GameType_SLYZ];
    NSString * tempPath=[ NSTemporaryDirectory() stringByAppendingPathComponent:tempFile];
    if([[NSFileManager defaultManager]fileExistsAtPath:tempPath]){
        //读取文件
        NSData *data=[NSData dataWithContentsOfFile:tempPath];
        NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%f",[dataString floatValue]&&[dataString floatValue]<1);
        if ([dataString floatValue]>0&&[dataString floatValue]<1) {
            btn.bgLayer.hidden = NO;
            [btn setProcess:[dataString floatValue]];
        }
        
    }
    
    NSString *tempFile2 =[NSString stringWithFormat:@"%@Temp.txt",GameType_CDX];
    NSString * tempPath2=[ NSTemporaryDirectory() stringByAppendingPathComponent:tempFile2];
    if([[NSFileManager defaultManager]fileExistsAtPath:tempPath2]){
        //读取文件
        NSData *data=[NSData dataWithContentsOfFile:tempPath2];
        NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if ([dataString floatValue]>0&&[dataString floatValue]<1) {
            btn2.bgLayer.hidden = NO;
            [btn2 setProcess:[dataString floatValue]];
        }
       
    }
}

#pragma mark-按钮事件
-(void)btnClick{
    if (!slyzIsSel) {
        gType=GameType_SLYZ;
        [self  requestData];
    }
   
}

-(void)btn2Click{
    if (!cdxIsSel) {
        gType=GameType_CDX;
        [self  requestData];
    }
    
    
}

//1是时来运转
//2是猜大小
#pragma mark --请求版本号
-(void)requestData{
//    NSString *url = [NSString stringWithFormat:@"%@?=%d",,1];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30.0f;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *dict;
    if ([gType isEqualToString:GameType_SLYZ]) {
        slyzIsSel = YES;
        dict = @{@"gameType":@"1"};
    }
    else if([gType isEqualToString:GameType_CDX]){
        dict = @{@"gameType":@"2"};
         cdxIsSel = YES;
    }
    [manager GET:GameUpdateAddressUrl
       parameters:dict
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
              NSDictionary *dict;
              NSLog(@"%@",string);
              if ([responseObject isKindOfClass:[NSDictionary class]]) {
                  dict = responseObject;
              }else {
                  dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
              }
              
              [self startGameMethodWithNewVersion:[dict[@"data"] integerValue]];

              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self startGameMethodWithNewVersion:0];
          }];
}

#pragma mark-游戏入口
-(void)startGameMethodWithNewVersion:(NSInteger)newVersion{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    //从系统偏好设置中取出游戏版本号
    NSString *gameVersion = [NSString stringWithFormat:@"%@_gameVersion",gType];
    NSString *version=[[NSUserDefaults standardUserDefaults]objectForKey:gameVersion];
    //版本为空,说明当前没有游戏目录
    if (version) {
        if ([version integerValue]<newVersion) {
            //有新版本时,先删除旧版本
            if ([self deleteOldVersionGame]) {
                //删除成功，下载新版本游戏
                [self loadGameZipWithUrl:[NSString stringWithFormat:@"%@/%@.zip",GameAddressUrl,gType]];
                return;
            }
            else if ([filemanager fileExistsAtPath:[[self getGamePahtUrl] stringByAppendingString:@".zip"]]) {
               
                 [self loadGameZipWithUrl:[NSString stringWithFormat:@"%@/%@.zip",GameAddressUrl,gType]];
            }
        }
        else{
            //游戏的目录地址
            NSString* gamefilePath =[self getGamePahtUrl];
            if ([filemanager fileExistsAtPath:gamefilePath]) {
                //存在游戏目录加载游戏
                [self openLocalCDXWithDocument:nil];
            }
            else{
                //游戏目录不存在，需要下载游戏并解压
                [self loadGameZipWithUrl:[NSString stringWithFormat:@"%@/%@.zip",GameAddressUrl,gType]];
            }
        }
    }
    else{
        //下载游戏,避免存在压缩包，多次加载游戏的问题
        [self downLoadGame];
    }
}


#pragma mark-下载游戏
-(void)downLoadGame{
     NSFileManager *filemanager = [NSFileManager defaultManager];
    //下载游戏的本地地址
    NSString * documentpath= [self getGamePahtUrl];
    NSString* unzipfilePath =[documentpath stringByAppendingString:@".zip"];
    if(![filemanager fileExistsAtPath:unzipfilePath]){
        //下载游戏，下载成功后解压
        [self loadGameZipWithUrl:[NSString stringWithFormat:@"%@/%@.zip",GameAddressUrl,gType]];
    }else{
        //如果存在压缩包
         //下载游戏，下载成功后解压
        [self loadGameZipWithUrl:[NSString stringWithFormat:@"%@/%@.zip",GameAddressUrl,gType]];
    }
}

#pragma mark - 获取压缩后游戏地址
-(NSString*)getGamePahtUrl{
    //游戏的目录地址
    NSString * documentpath= [self getGamePath];
    NSString* gamefilePath = [documentpath stringByAppendingFormat:@"/%@",gType] ;
    return  gamefilePath;
}

#pragma mark - 获取压缩包游戏地址
-(NSString *)getGamePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentpath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return documentpath;
}

#pragma mark-获取进度目录
-(NSString *)getProcessDocument{
    //进度目录
    NSString * tempPath =nil ;
    if ([gType isEqualToString:GameType_SLYZ]) {
        NSString *tempFile =[NSString stringWithFormat:@"%@Temp.txt",GameType_SLYZ];
        tempPath=[ NSTemporaryDirectory() stringByAppendingPathComponent:tempFile];
    }
    else if ([gType isEqualToString:GameType_CDX]) {
        NSString *tempFile =[NSString stringWithFormat:@"%@Temp.txt",GameType_CDX];
        tempPath=[ NSTemporaryDirectory() stringByAppendingPathComponent:tempFile];
    }
    return  tempPath;
}

#pragma mark -下载游戏
-(void)loadGameZipWithUrl:(NSString *)gameUrl{

    if ([gType isEqualToString:GameType_SLYZ]) {
        if (slyzBtn.instructionsLayer.strokeEnd !=1) {
             slyzBtn.bgLayer.hidden = NO;
        }
    }
    else if([gType isEqualToString:GameType_CDX]){
        if (cdxBtn.instructionsLayer.strokeEnd !=1) {
            cdxBtn.bgLayer.hidden = NO;
        }
    }
    
    //进度缓存目录
    NSString *tempPath  = [self getProcessDocument];
    
    //下载游戏的本地地址
    NSString * documentpath= [self getGamePahtUrl];
    NSString* unzipfilePath =[documentpath stringByAppendingString:@".zip"];
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    //下载地址
    NSURL *url = [NSURL URLWithString:gameUrl];
    NSURLRequest * request = [NSURLRequest  requestWithURL:url];
    
    unsigned long long  downloadedBytes =0;
    //检查文件是否已经下载了一部分
    if ([filemanager fileExistsAtPath:unzipfilePath])//如果存在,说明有缓存文件
    {
        downloadedBytes = [self fileSizeAtPath:unzipfilePath];//计算缓存文件的大小
        if(downloadedBytes>0){
            NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
            
            [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
            request = mutableURLRequest;
            NSLog(@"==============断点下载");
        }
    }
    //初始化队列
    NSOperationQueue *queue = [[NSOperationQueue alloc ]init];
    //不使用缓存，避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    //设置存储路径
    op.outputStream = [NSOutputStream outputStreamToFileAtPath:unzipfilePath append:YES];
    __block typeof(op) operation = op;
    // 下载进度
    [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        CGFloat precent =((float)totalBytesRead + downloadedBytes) / (totalBytesExpectedToRead + downloadedBytes);
        //设置进度
         NSLog(@"process ==>%f",precent);
        NSString *stringUrl = [operation.request.URL absoluteString];
        //时来运转
        if ([stringUrl isEqualToString:[NSString stringWithFormat:@"%@/%@.zip",GameAddressUrl,GameType_SLYZ]]) {
            slyzBtn.bgLayer.hidden = NO;
            [slyzBtn setProcess:precent];
        }
        else if([stringUrl isEqualToString:[NSString stringWithFormat:@"%@/%@.zip",GameAddressUrl,GameType_CDX]]){
            cdxBtn.bgLayer.hidden = NO;
            [cdxBtn setProcess:precent];
        }
        NSString * progress = [NSString stringWithFormat:@"%.3f",((float)totalBytesRead + downloadedBytes) / (totalBytesExpectedToRead + downloadedBytes)];
        [progress writeToFile:tempPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }];
    //下载成功
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"下载成功");
        NSString *stringUrl = [operation.request.URL absoluteString];
        NSString * documentpath= [self getGamePath];
        if ([stringUrl isEqualToString:[NSString stringWithFormat:@"%@/%@.zip",GameAddressUrl,GameType_SLYZ]]) {
             slyzIsSel = NO;
             slyzBtn.bgLayer.hidden = YES;
             //下载完成,解压游戏，并删除zip包
             [self unZipGameWithName:[NSString stringWithFormat:@"%@/%@",documentpath,GameType_SLYZ]];
        }
        else if([stringUrl isEqualToString:[NSString stringWithFormat:@"%@/%@.zip",GameAddressUrl,GameType_CDX]]){
            
             cdxIsSel = NO;
             cdxBtn.bgLayer.hidden = YES;
             //下载完成,解压游戏，并删除zip包
             [self unZipGameWithName:[NSString stringWithFormat:@"%@/%@",documentpath,GameType_CDX]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"下载失败");
        NSString *stringUrl = [operation.request.URL absoluteString];
        if ([stringUrl isEqualToString:[NSString stringWithFormat:@"%@/%@.zip",GameAddressUrl,GameType_SLYZ]]) {
            slyzIsSel = NO;
        }
        else if([stringUrl isEqualToString:[NSString stringWithFormat:@"%@/%@.zip",GameAddressUrl,GameType_CDX]]){
            
            cdxIsSel = NO;
        }
    }];
    //开始下载
//    [op start];
    [queue addOperation:op];
}

#pragma mark-计算缓存文件大小的方法
- (unsigned long long)fileSizeAtPath:(NSString *)fileAbsolutePath {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fileAbsolutePath]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:fileAbsolutePath error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}


#pragma mark-删除旧版本游戏
-(BOOL)deleteOldVersionGame{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    //下载游戏的本地地址
    NSString* gamefilePath= [self getGamePahtUrl];
    if ([filemanager fileExistsAtPath:gamefilePath]) {
        //删除本地游戏
        if ([filemanager removeItemAtPath:gamefilePath error:nil]) {
            NSLog(@"删除成功");
            return  YES;
        }
    }
    return  NO;
}


#pragma mark-解压游戏，删除.zip,并存储游戏版本
-(void)unZipGameWithName:(NSString *)documentpath{
     NSFileManager *filemanager = [NSFileManager defaultManager];
    //下载游戏的本地地址
    NSString* unzipfilePath =[documentpath stringByAppendingString:@".zip"];
    if (unzipfilePath) {
        // 解压
        BOOL isAlerady=[SSZipArchive unzipFileAtPath:unzipfilePath toDestination:documentpath];
        if (isAlerady&&[filemanager fileExistsAtPath:unzipfilePath]) { //解压成功删除.zip
            if ([filemanager removeItemAtPath:unzipfilePath error:nil]) {
                NSLog(@"删除成功");
            }
        }
    }
    //更新版本号，从文件中读取
    NSString *path = [documentpath stringByAppendingString:@"/version.txt"];
    //存入第一个版本信息
    if ([filemanager fileExistsAtPath:path]) {
        //读取文件
        NSData *data=[NSData dataWithContentsOfFile:path];
        NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSString * gameName = [[documentpath pathComponents]lastObject];
        //将游戏版本存入偏好设置，避免了每次都读取文件
        NSString *gameVersion = [NSString stringWithFormat:@"%@_gameVersion",gameName];
        [[NSUserDefaults standardUserDefaults]setValue:dataString forKey:gameVersion];
        [[NSUserDefaults standardUserDefaults] synchronize];
    
        //打开游戏
//        [self openLocalCDXWithDocument:documentpath];
    }

}

#pragma mark-打开游戏
-(void)openLocalCDXWithDocument:(NSString *)document{
    //加载本地游戏
    NSString *gameName= nil;
    NSString * documentpath=nil;
    //设置游戏的标题
//    if (document) {
//        documentpath=document;
//        gameName = [[document pathComponents]lastObject];
//        if ([gameName isEqualToString:GameType_SLYZ]) {
//            gameName = GameString_SLYZ;
//        }
//        else if ([gameName isEqualToString:GameType_CDX]) {
//            gameName = GameString_CDX;
//        }
//    }
//    else{
       documentpath= [self getGamePahtUrl];
        if ([gType isEqualToString:GameType_SLYZ]) {
            gameName = GameString_SLYZ;
            slyzIsSel = NO;
        }
        else if ([gType isEqualToString:GameType_CDX]) {
            gameName = GameString_CDX;
            cdxIsSel = NO;
        }
//    }
  
    NSString *path = [documentpath stringByAppendingString:@"/index.html"];
    NSString *newurl=[NSString stringWithFormat:@"%@%@%@",path,@"?memberId=",@"10027960623"];
    NSURL * url=[NSURL URLWithString:newurl];
    GameWebController * gameWeb = [[GameWebController alloc]init];
    gameWeb.gameTitle =gameName;
    gameWeb.gameDetialUrl =url;
    [self.navigationController pushViewController:gameWeb animated:YES];
}

#pragma mark-从游戏目录获取游戏版本号
-(NSInteger)getVersionFromTxt{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    //下载游戏的本地地址
    NSString * documentpath= [self getGamePahtUrl];
    NSString *path = [documentpath stringByAppendingString:@"/version.txt"];
    //存入第一个版本信息
    if ([filemanager fileExistsAtPath:path]) {
        //读取文件
        NSData *data=[NSData dataWithContentsOfFile:path];
        NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        return [dataString integerValue];
    }
    return 0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
