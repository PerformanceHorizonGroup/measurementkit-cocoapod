//
//  PHGActiveFingerPrinter.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 25/02/2015.
//
//

#import "PHNActiveFingerprinter.h"
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>
#import "PHNHostHelper.h"

#import <SafariServices/SafariServices.h>

@interface PHNActiveFingerprinter() <UIWebViewDelegate, SFSafariViewControllerDelegate>

//ideally IDFA, if not, some kind of local identifier.
@property(nonatomic, retain) NSString* localID;
@property(nonatomic, retain) NSString* queryParameter;

@property(nonatomic, retain) UIWebView* webview;
@property(nonatomic, retain) SFSafariViewController* safariview;

@property(nonatomic, retain) PHNHostHelper* hostHelper;

@end

@implementation PHNActiveFingerprinter

- (instancetype) initWithHostHelper:(PHNHostHelper*)helper
{
    if (self =  [super init]) {
        _hostHelper = helper;
        _fingerprintComplete = NO;
        _fingerprintInProgress = NO;
    }
    
    return self;
}

- (void) clearCompleted {
    self.fingerprintComplete = NO;
    
    [self.safariview.view removeFromSuperview];
    [self.webview removeFromSuperview];
    
    self.safariview = nil;
    self.webview = nil;
}

- (void) fingerprintWithIDFA:(NSString*)idfa {
    self.localID = idfa;
    self.queryParameter = @"idfa";
    [self fingerprint];
}

- (void) fingerprintWithUUID:(NSString*)uuid {
    self.localID = uuid;
    self.queryParameter = @"uuid";
    [self fingerprint];
}

- (void) fingerprint
{
    if (!(self.localID&& self.queryParameter)) {
        return;
    }
    
    self.fingerprintInProgress = YES;
    
    PHNActiveFingerprinter* __weak weakself = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        //if we're using the safari view controller, we can do some direct cookie matching.
        if (NSClassFromString(@"SFSafariViewController") && weakself.localID) {
        
            weakself.safariview = [[SFSafariViewController alloc] initWithURL:
                               [NSURL URLWithString:[NSString stringWithFormat:@"%@/alias?%@=%@",
                                                     [weakself.hostHelper urlStringForTracking],
                                                     weakself.queryParameter ?: @"UUID",
                                                     weakself.localID]]];
            weakself.safariview.delegate = self;
            [weakself.safariview.view setFrame:CGRectMake(0, 0, 0, 0)];
            
            UIWindow * window = [UIApplication sharedApplication].windows[0];
            [window.rootViewController.view addSubview:weakself.safariview.view];
        }
        else {
            weakself.webview = [[UIWebView alloc] init];
            weakself.webview.delegate= self;
            
            [weakself.webview loadHTMLString:@"" baseURL:[NSURL URLWithString:@"http://www.performancehorizon.com"]];
        }
    }];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    if ([self.delegate respondsToSelector:@selector(activeFingerprinterDidCompleteWithResults:)])
    {
        NSString* useragent = [self.webview stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        NSDictionary* activeresults = @{@"useragent":useragent};
        
        [self.delegate activeFingerprinterDidCompleteWithResults:activeresults];
    }
    
    self.fingerprintComplete = YES;
    self.fingerprintInProgress = NO;
    
    [self.webview removeFromSuperview];
    self.webview = nil;
}

- (void) safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    self.fingerprintInProgress = NO;
    
    if (didLoadSuccessfully) {
        self.fingerprintComplete = YES;
        
        [self.delegate activeFingerprinterDidCompleteWithResults:nil];
        
        [self.safariview.view removeFromSuperview];
        self.safariview = nil;
    }
}



@end
