//
//  ISArgumentParserTests.m
//  ISArgumentParserTests
//
//  Created by Jason Barrie Morley on 30/11/2014.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <ISArgumentParser/ISArgumentParser.h>

@interface ISArgumentParserTests : XCTestCase

@property (nonatomic, readwrite, strong) ISArgumentParser *parser;

@end

@implementation ISArgumentParserTests

- (void)setUp
{
    [super setUp];
    self.parser = [ISArgumentParser argumentParserWithDescription:@"Test argument parser."];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testSingleArgument
{
    [self.parser addArgumentWithName:@"argument1"
                     alternativeName:nil
                                type:ISArgumentParserTypeString
                        defaultValue:nil
                              action:ISArgumentParserActionStore
                         description:@"first argument"];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"value1"] error:&error];
    XCTAssertEqualObjects(options, @{@"argument1": @"value1"}, @"Unexpected argument results.");
}

- (void)testMultipleArguments
{
    [self.parser addArgumentWithName:@"argument1"
                     alternativeName:nil
                                type:ISArgumentParserTypeString
                        defaultValue:nil
                              action:ISArgumentParserActionStore
                         description:@"first argument"];
    [self.parser addArgumentWithName:@"argument2"
                     alternativeName:nil
                                type:ISArgumentParserTypeString
                        defaultValue:nil
                              action:ISArgumentParserActionStore
                         description:@"second argument"];
    [self.parser addArgumentWithName:@"argument3"
                     alternativeName:nil
                                type:ISArgumentParserTypeString
                        defaultValue:nil
                              action:ISArgumentParserActionStore
                         description:@"third argument"];

    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"value1", @"value2", @"value3"]
                                                  error:&error];
    NSDictionary *expected = @{@"argument1": @"value1",
                               @"argument2": @"value2",
                               @"argument3": @"value3"};
    XCTAssertEqualObjects(options, expected, @"Unexpected argument results.");
}

- (void)testArgumentWithAlternativeNameFails
{
    
}

// Check that optional arguments with defaults are processed in order.

- (void)testBooleanFlagSet
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:nil
                                type:ISArgumentParserTypeBool
                        defaultValue:nil
                              action:ISArgumentParserActionStoreTrue
                         description:@"boolean flag"];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"--flag"] error:&error];
    XCTAssertEqualObjects(options, @{@"flag": @YES}, @"Unexpected argument results.");
}

- (void)testBooleanFlagUnset
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:nil
                                type:ISArgumentParserTypeBool
                        defaultValue:nil
                              action:ISArgumentParserActionStoreTrue
                         description:@"boolean flag"];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application"] error:&error];
    XCTAssertEqualObjects(options, @{}, @"Unexpected argument results.");
}

- (void)testBooleanFlagWithDefaultSet
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:nil
                                type:ISArgumentParserTypeBool
                        defaultValue:@NO
                              action:ISArgumentParserActionStoreTrue
                         description:@"boolean flag"];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"--flag"] error:&error];
    XCTAssertEqualObjects(options, @{@"flag": @YES}, @"Unexpected argument results.");
}

- (void)testBooleanFlagWithDefaultUnset
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:nil
                                type:ISArgumentParserTypeBool
                        defaultValue:@NO
                              action:ISArgumentParserActionStoreTrue
                         description:@"boolean flag"];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application"] error:&error];
    XCTAssertEqualObjects(options, @{@"flag": @NO}, @"Unexpected argument results.");
}

- (void)testBooleanFlagWithAlternativeSet
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:@"-f"
                                type:ISArgumentParserTypeBool
                        defaultValue:nil
                              action:ISArgumentParserActionStoreTrue
                         description:@"boolean flag"];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"-f"] error:&error];
    XCTAssertEqualObjects(options, @{@"flag": @YES}, @"Unexpected argument results.");
}

- (void)testBooleanFlagWithAlternativeUnset
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:@"-f"
                                type:ISArgumentParserTypeBool
                        defaultValue:nil
                              action:ISArgumentParserActionStoreTrue
                         description:@"boolean flag"];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application"] error:&error];
    XCTAssertEqualObjects(options, @{}, @"Unexpected argument results.");
}

- (void)testOptionalArgument
{
    [self.parser addArgumentWithName:@"--optional"
                     alternativeName:nil
                                type:ISArgumentParserTypeString
                        defaultValue:nil
                              action:ISArgumentParserActionStore
                         description:@"some optional argument"];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"--optional", @"value"] error:&error];
    NSDictionary *expected = @{@"optional": @"value"};
    XCTAssertEqualObjects(options, expected, @"Unexpected argument results");
    [self.parser printHelp];
}

- (void)testHelp
{
    [self.parser addArgumentWithName:@"url"
                     alternativeName:nil
                                type:ISArgumentParserTypeString
                        defaultValue:nil
                              action:ISArgumentParserActionStore
                         description:@"the url to download"];
    [self.parser printHelp];
}

@end
