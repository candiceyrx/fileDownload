//
//  LLSessionController.m
//  fileDownloadDemo
//
//  Created by Candice on 16/5/29.
//  Copyright © 2016年 Candice. All rights reserved.
//

#import "LLSessionController.h"

@interface LLSessionController ()<NSURLSessionDownloadDelegate>
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *myProgress;
@property (weak, nonatomic) IBOutlet UIButton *sessionButton;
//下载任务
@property (strong,nonatomic)NSURLSessionDownloadTask *downloadTask;
//resumeData记录下载位置
@property(strong,nonatomic)NSData *resumeData;
//session
@property(strong,nonatomic)NSURLSession *session;

@end

@implementation LLSessionController

- (NSURLSession *)session{
    if (nil == _session) {
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

//从0开始下载
- (void)startDownload{
    NSURL* url = [NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg"];
    
    //创建任务
    self.downloadTask = [self.session downloadTaskWithURL:url];
    
    //开始任务
    [self.downloadTask resume];
}

//恢复下载
- (void)resume{
    //传入上次暂停下载返回的数据，就可以恢复下载
    self.downloadTask = [self.session downloadTaskWithResumeData:self.resumeData];
    [self.downloadTask resume];//开始任务
    self.resumeData = nil;
}

//暂停
- (void)pause{
    __weak typeof(self) selfVC = self;
    [self.downloadTask cancelByProducingResumeData:^(NSData *resumeData){
          //resumeData:包含了继续下载的开始位置/下载的URL
        selfVC.resumeData = resumeData;
        selfVC.downloadTask = nil;
    }];
}

#pragma mark-----NSURLSessionDownloadDelegate---------

//下载完毕后会调用 location:文件临时地址
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    //response.suggestedFilename ： 建议使用的文件名，一般跟服务器端的文件名一致
    NSString *file = [caches stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    
    //将临时文件剪切或者复制Caches文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //AtPath:剪切前的文件路径
    //ToPath:剪切后的文件路径
    [fileManager moveItemAtPath:location.path toPath:file error:nil];
    
    //下载完成后再改变背景图片
     [self.sessionButton setBackgroundImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    
    //提示下载完成
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"下载完成" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertC animated:YES completion:nil];
    [alertC addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
    }]];
}

/**
 *  每次写入沙盒完毕调用
 *  在这里面监听下载进度，totalBytesWritten/totalBytesExpectedToWrite
 *
 *  @param bytesWritten              这次写入的大小
 *  @param totalBytesWritten         已经写入沙盒的大小
 *  @param totalBytesExpectedToWrite 文件总大小
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
     self.myProgress.progress = (double)totalBytesWritten/totalBytesExpectedToWrite;
    self.progressLabel.text =  [NSString stringWithFormat:@"下载进度:%f",(double)totalBytesWritten/totalBytesExpectedToWrite];

}

//恢复下载后调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{

}

- (IBAction)buttonClick:(UIButton *)sender {
     //按钮状态取反
    sender.selected = !sender.isSelected;
    
    if (sender.selected) {
        [sender setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        if (self.resumeData) {// 继续下载
            [self resume];
        }else{// 从0开始下载
            [self startDownload];
        }
    } else {
        [sender setBackgroundImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
        [self pause];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
