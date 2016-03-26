//
//  ViewController.m
//  UPPayDemo
//
//  Created by zhangyi on 15/11/19.
//  Copyright © 2015年 UnionPay. All rights reserved.
//

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "ViewController.h"
#import "UPPaymentControl.h"


#define KBtn_width        200
#define KBtn_height       80
#define KXOffSet          (self.view.frame.size.width - KBtn_width) / 2
#define KYOffSet          80
#define kCellHeight_Normal  50
#define kCellHeight_Manual  145

#define kVCTitle          @"商户测试"
#define kBtnFirstTitle    @"获取订单，开始测试"
#define kWaiting          @"正在获取TN,请稍后..."
#define kNote             @"提示"
#define kConfirm          @"确定"
#define kErrorNet         @"网络错误"
#define kResult           @"支付结果：%@"


#define kMode_Development             @"01"
#define kURL_TN_Normal                @"http://101.231.204.84:8091/sim/getacptn"
#define kURL_TN_Configure             @"http://101.231.204.84:8091/sim/app.jsp?user=123456789"


@interface ViewController ()<NSURLConnectionDataDelegate>
{
     NSMutableData* _responseData;
    CGFloat _maxWidth;
    CGFloat _maxHeight;
}

@property(nonatomic, copy)NSString *tnMode;

- (void)startNetWithURL:(NSURL *)url;


@end

@implementation ViewController
@synthesize contentTableView;
@synthesize tnMode;

- (void)dealloc
{
    self.contentTableView = nil;
    self.tnMode = nil;

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
 
    self.title = kVCTitle;
    
      _maxWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    _maxHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.contentTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _maxWidth, _maxHeight) style:UITableViewStyleGrouped] ;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView;
    });
    
    [self.view addSubview:self.contentTableView];
}



#pragma mark - connection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response
{
    NSHTTPURLResponse* rsp = (NSHTTPURLResponse*)response;
    NSInteger code = [rsp statusCode];
    if (code != 200)
    {
        [connection cancel];
    }
    else
    {
        _responseData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSString* tn = [[NSMutableString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    if (tn != nil && tn.length > 0)
    {
        
        NSLog(@"tn= %@",tn);
        
        [[UPPaymentControl defaultControl] startPay:tn fromScheme:@"UPPayDemo" mode:self.tnMode viewController:self];
        
    }

}

#pragma mark UPPayPluginResult
- (void)UPPayPluginResult:(NSString *)result
{
    NSString* msg = [NSString stringWithFormat:kResult, result];
    NSLog(@"msg = === %@" , msg);
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight_Normal;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 2;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    switch (indexPath.row) {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"普通订单";
            cell.detailTextLabel.text = @"mode=01";
        }
            
            break;
        case 1:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"配置用户123456789";
            cell.detailTextLabel.text = @"mode=01";
        }
            break;
            
            
        default:
            break;
    }
    
    

    return cell;
}

#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row) {
        case 0:
            
            self.tnMode = kMode_Development;
            [self startNetWithURL:[NSURL URLWithString:kURL_TN_Normal]];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            break;
        case 1:
            self.tnMode = kMode_Development;
            [self startNetWithURL:[NSURL URLWithString:kURL_TN_Configure]];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
            
        default:
            break;
    }
}


- (void)startNetWithURL:(NSURL *)url
{
    
    NSURLRequest * urlRequest=[NSURLRequest requestWithURL:url];
    NSURLConnection* urlConn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    [urlConn start];
}



@end

