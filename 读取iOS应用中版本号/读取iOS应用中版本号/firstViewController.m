#import "firstViewController.h"
#import "AFNetworking.h"
@interface firstViewController ()
//@property (retain, nonatomic) IBOutlet UIProgressView *sliderView;
//@property (retain, nonatomic) IBOutlet UILabel *progress;
@property (nonatomic, retain) AFHTTPRequestOperation  * operation;
@end

@implementation firstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * txtTempPath =[ NSTemporaryDirectory() stringByAppendingPathComponent:@"mvTemp/mv.txt"];
    NSFileManager *  fileManager =[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:txtTempPath])
    {
//        _sliderView.progress =  [[NSString stringWithContentsOfFile:txtTempPath encoding:NSUTF8StringEncoding error:nil] floatValue];
    }
    
//    else _sliderView.progress = 0;
//    _progress.text = [NSString stringWithFormat:@"%.2f%%",_sliderView.progress *100];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"%@", NSHomeDirectory());
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)start:(UIButton *)sender
{
    if([sender.currentTitle isEqualToString:@"开始下载"])
    {
        [sender setTitle:@"暂停下载" forState:UIControlStateNormal];
        
        NSURL * url = [NSURL URLWithString:@"http://www.demaxiya.com/app/index.php?m=play&vid=29996&quality=1"];
        NSString * CachePath =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject];
        NSFileManager *  fileManager =[NSFileManager defaultManager];
        NSLog(@"%@",CachePath);
        NSString * folderPath = [CachePath stringByAppendingPathComponent:@"mv"];
        NSString * tempPath =[ NSTemporaryDirectory() stringByAppendingPathComponent:@"mvTemp"];
        //判断缓存文件夹和视频存放文件夹是否存在,如果不存在,就创建一个文件夹
        if (![fileManager fileExistsAtPath:folderPath])
        {
            [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        //
        if (![fileManager fileExistsAtPath:tempPath])
        {
            [fileManager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString * tempFilePath = [tempPath stringByAppendingPathComponent:@"mv.temp"];//缓存路径
        NSString * mvFilePath = [folderPath stringByAppendingPathComponent:@"mv.mp4"];//文件保存路径
        NSString * txtFilePath = [tempPath stringByAppendingPathComponent:@"mv.txt"];//保存重启程序下载的进度
        
        unsigned long long  downloadedBytes =0;
        NSURLRequest * request = [NSURLRequest  requestWithURL:url];
        
        if ([fileManager fileExistsAtPath:tempFilePath])//如果存在,说明有缓存文件
        {
            downloadedBytes = [self fileSizeAtPath:tempFilePath];//计算缓存文件的大小
            NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
            
            [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
            request = mutableURLRequest;
            NSLog(@"==============断点下载");
        }
        
        
        if (![fileManager  fileExistsAtPath:mvFilePath]) {
            
            [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
            self.operation= [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [_operation setOutputStream:[NSOutputStream outputStreamToFileAtPath: tempFilePath append:YES]];
            
            [_operation  setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//                _sliderView.progress = ((float)totalBytesRead + downloadedBytes) / (totalBytesExpectedToRead + downloadedBytes);
//                _progress.text = [NSString stringWithFormat:@"%.2f%%",_sliderView.progress *100];
                
                NSString * progress = [NSString stringWithFormat:@"%.3f",((float)totalBytesRead + downloadedBytes) / (totalBytesExpectedToRead + downloadedBytes)];
                [progress writeToFile:txtFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }];
            
            [_operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 
                 [fileManager moveItemAtPath:tempFilePath toPath:mvFilePath error:nil];//把下载完成的文件转移到保存的路径
                 [fileManager removeItemAtPath:txtFilePath error:nil];//删除保存进度的txt文档
                 
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error)
             
             {
                 
                 
             }];
            [_operation start];
        }else
        {
            
        }
    }
    else
    {
        
        [sender setTitle:@"开始下载" forState:UIControlStateNormal];
        [self.operation cancel];
        self.operation = nil;
        
    }
    
}
//计算缓存文件大小的方法
- (unsigned long long)fileSizeAtPath:(NSString *)fileAbsolutePath {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new];
    if ([fileManager fileExistsAtPath:fileAbsolutePath]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:fileAbsolutePath error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}


@end