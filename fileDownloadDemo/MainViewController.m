//
//  MainViewController.m
//  fileDownloadDemo
//
//  Created by Candice on 16/5/29.
//  Copyright © 2016年 Candice. All rights reserved.
//

#import "MainViewController.h"
#import "LLConnectionController.h"
#import "LLSessionController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *introImageView;

- (IBAction)conClick:(UIButton *)sender;
- (IBAction)sessionClick:(UIButton *)sender;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.titleTextAttributes = @{};
    self.title = @"Download";
    
    //小文件下载
   // NSData dataWithContentsOfURL
    // NSURLConnection
    
    NSURL *url = [NSURL URLWithString:@"http://pic9.nipic.com/20100904/4845745_195609329636_2.jpg"];
    [self downloadImageWithUrl:url];
    
    //[self downloadImage2withUrl:url];
    
}

- (void)downloadImageWithUrl:(NSURL *)url{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       //发送一个get请求
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        //回到主线程刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            self.introImageView.image = [UIImage imageWithData:data];
        });
    });
}

/*
- (void)downloadImage2withUrl:(NSURL *)url{
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        self.introImageView.image = [UIImage imageWithData:data];
    }];
}*/

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

- (IBAction)conClick:(UIButton *)sender {
    NSLog(@"connection");
    LLConnectionController *llController = [[LLConnectionController alloc]initWithNibName:@"LLConnectionController" bundle:nil];
    [self.navigationController pushViewController:llController animated:YES];

}

- (IBAction)sessionClick:(UIButton *)sender {
    NSLog(@"session");
    LLSessionController *llSessionController = [[LLSessionController alloc]initWithNibName:@"LLSessionController" bundle:nil];
    [self.navigationController pushViewController:llSessionController animated:YES];

}
@end
