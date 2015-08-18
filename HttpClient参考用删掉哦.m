//
//  HttpClient.m
//  vZhuLi
//
//  Created by Shen Jun on 15/7/14.
//  Copyright (c) 2015年 YJM. All rights reserved.
//
//111
//222

#import "HttpClient.h"
#import "RTJSONResponseSerializerWithData.h"
#import "JSONKit.h"

#define uid @"ZrxWnlA15PyQiWdCtPJNm7xKctP7a1"
#define key @"Meem6fLGnBdUTvQFOlOWQF8x7fttAK6byvlRGMc1W2vXTwmzHX9TEWAQRiGinTfV"

@interface HttpClient() <SRWebSocketDelegate>
// 网络请求
@property (strong, nonatomic) AFHTTPRequestOperation *requestOperaion;
// 请求对象
@property (strong, nonatomic) NSMutableURLRequest *request;

// socket对象
@property (strong, nonatomic) SRWebSocket *webSocket;

@end

static id _instance;

@implementation HttpClient

#pragma mark - 初始化
- (instancetype)init
{
    if (self = [super init]) {
        // 初始化 请求对象
        [self initRequest];
    }
    return self;
}

#pragma mark - 所有实例化方法, 最终会调用此方法
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

#pragma mark - 新建单例对象
+ (instancetype)shareHttpClient
{
    return [[HttpClient alloc] init];
}

#pragma mark - 初始化 请求对象
- (void)initRequest
{
    self.request = [[NSMutableURLRequest alloc] init];
    self.request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    self.request.timeoutInterval = 30;
    [self.request addValue:@"third" forHTTPHeaderField:@"platform"];
    [self.request addValue:@"third" forHTTPHeaderField:@"usertype"];
    [self.request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.request addValue:uid forHTTPHeaderField:@"uid"];
    [self.request addValue:key forHTTPHeaderField:@"key"];
    
    self.requestOperaion = [[AFHTTPRequestOperation alloc] initWithRequest:self.request];
    self.requestOperaion.responseSerializer = [RTJSONResponseSerializerWithData serializer];
}

#pragma mark - 初始化Socket对象
- (void)initWebSocket
{
    self.webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"http://aide.chat.abstack.com/chatsocket/0/0/websocket"]];
    self.webSocket.delegate = self;
    [self.webSocket open];
}

#pragma mark - SRWebSocketDelegate
#pragma mark 已经连接
- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    //MyLog(@"%zd", webSocket.readyState);
    if ([self.httpClientDelegate respondsToSelector:@selector(httpClientDelegateSocketDidOpen:)]) {
        [self.httpClientDelegate httpClientDelegateSocketDidOpen:webSocket];
    }
}

#pragma mark 连接失败
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    //MyLog(@"%@", error);
    if ([self.httpClientDelegate respondsToSelector:@selector(httpClientDelegateSocket:didFailWithError:)]) {
        [self.httpClientDelegate httpClientDelegateSocket:webSocket didFailWithError:error];
    }
}

#pragma mark 接受Pong
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    //MyLog(@"%@", pongPayload);
    if ([self.httpClientDelegate respondsToSelector:@selector(httpClientDelegateSocket:didReceivePong:)]) {
        [self.httpClientDelegate httpClientDelegateSocket:webSocket didReceivePong:pongPayload];
    }}

#pragma mark 接受消息
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    //MyLog(@"%@", message);
    if ([self.httpClientDelegate respondsToSelector:@selector(httpClientDelegateSocket:didReceiveMessage:)]) {
        [self.httpClientDelegate httpClientDelegateSocket:webSocket didReceiveMessage:message];
    }
}

#pragma mark 关闭连接
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    if ([self.httpClientDelegate respondsToSelector:@selector(httpClientDelegateSocket:didCloseWithCode:reason:wasClean:)]) {
        [self.httpClientDelegate httpClientDelegateSocket:webSocket didCloseWithCode:code reason:reason wasClean:wasClean];
    }
}

#pragma mark - 请求头 请求
- (void)requestOperaionWithURl:(NSString *)urlStr
                    httpMethod:(NSString *)method
                    parameters:(id)parameters
                       success:(void (^)(AFHTTPRequestOperation*, id))success
                       failure:(void (^)(AFHTTPRequestOperation*, NSError *))failure
{
    NSURL *url = [NSURL URLWithString:urlStr];
    self.request.URL = url;
    self.request.HTTPMethod = method;
    
    // 设置 请求参数
    //[self.request setValuesForKeysWithDictionary:parameters];
    if (parameters) {
        self.request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    }
    
    // 发送
    [self.requestOperaion setCompletionBlockWithSuccess:success failure:failure];
    [self.requestOperaion start];
}

#pragma mark - socket 请求
- (void)socketRequestWithParameters:(id)parameters
{
    NSString *returnStr = [parameters JSONString];
    [self.webSocket send:returnStr];
}

@end
