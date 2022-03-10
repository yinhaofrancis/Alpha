//
//  AlphaOcTests.m
//  AlphaOcTests
//
//  Created by hao yin on 2021/9/6.
//

#import <XCTest/XCTest.h>
#import <Alpha/Alpha-Swift.h>
@interface AlphaOcTests : XCTestCase
@property(nonatomic,nonnull) AlphaBridge *bridge;
//@property(nonatomic,nonnull)
@property(nonatomic,nonnull) RestoreLog *log;
@property(nonatomic,nonnull) NSURLSession* session;
@end

@implementation AlphaOcTests

- (void)setUp {
    self.bridge = [[AlphaBridge alloc] initWithName:@"ddd" error:nil];
    self.session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    [self.bridge saveWithName:@"aaa" obj:@{@"dsds":@1,@"sdsd":@"sdsd",@"obj":@[@{@"s":@"dsds",@"dd":@3},@{@"s":@"dsds",@"dd":@3},@{@"s":@"dsds",@"dd":@3}]}];
    NSArray* dc = [self.bridge queryWithName:@"aaa" condition:nil value: @{}];
    NSLog(@"%@",dc);
    XCTAssertNotNil(dc);
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}
- (void)testExample2 {
    self.log = [[RestoreLog alloc] initWithName:@"go" error:nil];
    
    JSONType* type = [[JSONType alloc] init];
    XCTestExpectation* end = [[XCTestExpectation alloc] initWithDescription:@"end"];
    
    NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    NSURLSessionTask* task = [self.session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self.log writeWithRespone:response request:req data:data];
        [end fulfill];
    }];
    [task resume];
    [self waitForExpectations:@[end] timeout:5000];

    
    
    
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}
-(void)testQuery {
    self.log = [[RestoreLog alloc] initWithName:@"go" error:nil];

    XCTestExpectation* end = [[XCTestExpectation alloc] initWithDescription:@"end"];
    [self.log queryWithCallback:^(NSArray<Log *> * _Nonnull logs) {
        NSLog(@"%@",logs);
        [end fulfill];
    }];
    [self waitForExpectations:@[end] timeout:5000];
}
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
