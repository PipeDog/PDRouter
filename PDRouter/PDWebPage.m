//
//  PDWebPage.m
//  PDRouter
//
//  Created by liang on 2018/7/19.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDWebPage.h"

@interface PDWebPage () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *progressView;

@end

@implementation PDWebPage

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)loadRequest:(NSURLRequest *)request {
    if (!request) return;
    
    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.progressView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.progressView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.progressView stopAnimating];
}


#pragma mark - Getter Methods
- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.delegate = self;
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (UIActivityIndicatorView *)progressView {
    if (!_progressView) {
        CGSize size = CGSizeMake(40, 40);
        CGFloat left = (CGRectGetWidth(self.webView.frame) - size.width) / 2.f;
        CGFloat top = (CGRectGetHeight(self.webView.frame) - size.height) / 2.f;
        
        _progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _progressView.frame = CGRectMake(left, top, size.width, size.height);
        [self.webView addSubview:_progressView];
    }
    return _progressView;
}

@end
