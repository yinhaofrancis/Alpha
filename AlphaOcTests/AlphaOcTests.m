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
@end

@implementation AlphaOcTests

- (void)setUp {
    self.bridge = [[AlphaBridge alloc] initWithName:@"ddd" error:nil];
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

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
