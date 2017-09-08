//
//  PHNMeasurementSessionManager.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 23/03/2016.
//
//

#import "PHNMeasurementSessionManager.h"

@implementation PHNMeasurementSessionManager

#pragma mark - NSURLSessionDelegate

- (void) URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
  completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if ([challenge.protectionSpace.host isEqualToString:@"m.prf.hn"] &&
        [challenge.protectionSpace authenticationMethod] == NSURLAuthenticationMethodServerTrust) {
        SecTrustResultType trustevaluationresult;
        
        SecTrustEvaluate(challenge.protectionSpace.serverTrust, &trustevaluationresult);
        
        if (trustevaluationresult == kSecTrustResultProceed || trustevaluationresult == kSecTrustResultUnspecified) {
            NSURLCredential* credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }
        else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    }
}

#pragma mark NSURLSessionTaskDelegate

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    //reject invalid protection spaces.
    if ([challenge.protectionSpace.host isEqualToString:@"m.prf.hn"] &&
        [challenge.protectionSpace authenticationMethod] == NSURLAuthenticationMethodServerTrust) {
        
        SecTrustResultType trustevaluationresult;
        
        SecTrustEvaluate(challenge.protectionSpace.serverTrust, &trustevaluationresult);
        
        if (trustevaluationresult == kSecTrustResultProceed || trustevaluationresult == kSecTrustResultUnspecified) {
            NSURLCredential* credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }
        else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    }
    else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

@end
