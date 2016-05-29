//
//  LLConnectionController.m
//  fileDownloadDemo
//
//  Created by Candice on 16/5/29.
//  Copyright © 2016年 Candice. All rights reserved.
//

#import "LLConnectionController.h"

@interface LLConnectionController ()<NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIButton *urlButton;
@property (weak, nonatomic) IBOutlet UIProgressView *myProgress;
//用来写数据的文件句柄对象
@property (strong,nonatomic) NSFileHandle *writeHandle;

//文件的总长度
@property(assign,nonatomic)long long totalLength;

//当前已经写入的总大小
@property(assign,nonatomic)long long currentLength;

//连接对象
@property(strong,nonatomic)NSURLConnection *connection;

@end

@implementation LLConnectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)buttonClick:(UIButton *)sender {
   //状态取反
    sender.selected = !sender.isSelected;
    
    //断点续传
    //断点下载
    
    if (sender.selected) {//继续（开始）下载
      //改变显示图片
        [sender setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        
        //1.URL
        NSURL* url = [NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg"];
        //2.请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        //设置请求头
        NSString *range = [NSString stringWithFormat:@"bytes=%lld-",self.currentLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        //3.下载
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    } else {//暂停
       [sender setBackgroundImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
        [self.connection cancel];
        self.connection = nil;
    }
    

}

#pragma mark-----NSURLConnectionDataDelegate----------

//1.接收到服务器的响应就会调用
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"接收到服务器的响应");
    
    //如果文件已经存在，不执行一下操作
    if (self.currentLength) {
        return;
    }
    
    //文件路径
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    NSString *filepath = [caches stringByAppendingPathComponent:response.suggestedFilename];
    
    //创建一个空的文件到沙盒中
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:filepath contents:nil attributes:nil];
    
    //创建一个用来写数据的文件句柄对象
    self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:filepath];
    
    //获得文件的总大小
    self.totalLength = response.expectedContentLength;
}


//2.当接收到服务器返回的实体数据时调用（具体内容，可能被调用多次）
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSLog(@"接收到实体数据");
    
    //移动到文件的最后面
    [self.writeHandle seekToEndOfFile];
    
    //将数据写入沙盒
    [self.writeHandle writeData:data];
    
    //累计写入文件的长度
    self.currentLength += data.length;
    
    //下载进度
    self.myProgress.progress = (double)self.currentLength/self.totalLength;
    
    self.progressLabel.text = [NSString stringWithFormat:@"当前下载进度:%f",(double)self.currentLength/self.totalLength];
}

//3.加载完毕后调用（服务器的数据已经完全返回后）
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    //下载完成后改变背景图片
    [self.urlButton setBackgroundImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"下载已完成" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertC animated:YES completion:nil];
    [alertC addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
    }]];
    
    self.currentLength = 0;
    self.totalLength = 0;
    
    //关闭文件
    [self.writeHandle closeFile];
    self.writeHandle = nil;
}

//加载失败会调用
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"下载失败了:%@",error);
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
