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
                        defaultValue:nil
                              action:ISArgumentParserActionStore
                         description:@"first argument"];
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"value1"]];
    XCTAssertEqualObjects(options, @{@"argument1": @"value1"}, @"Unexpected argument results.");
}

- (void)testMultipleArguments
{
    [self.parser addArgumentWithName:@"argument1"
                     alternativeName:nil
                        defaultValue:nil
                              action:ISArgumentParserActionStore
                         description:@"first argument"];
    [self.parser addArgumentWithName:@"argument2"
                     alternativeName:nil
                        defaultValue:nil
                              action:ISArgumentParserActionStore
                         description:@"second argument"];
    [self.parser addArgumentWithName:@"argument3"
                     alternativeName:nil
                        defaultValue:nil
                              action:ISArgumentParserActionStore
                         description:@"third argument"];

    NSDictionary *options = [self.parser parseArguments:@[@"application", @"value1", @"value2", @"value3"]];
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
                        defaultValue:nil
                              action:ISArgumentParserActionStoreTrue
                         description:@"boolean flag"];
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"--flag"]];
    XCTAssertEqualObjects(options, @{@"flag": @YES}, @"Unexpected argument results.");
}

- (void)testBooleanFlagUnset
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:nil
                        defaultValue:nil
                              action:ISArgumentParserActionStoreTrue
                         description:@"boolean flag"];
    NSDictionary *options = [self.parser parseArguments:@[@"application"]];
    XCTAssertEqualObjects(options, @{}, @"Unexpected argument results.");
}

- (void)testBooleanFlagWithDefaultSet
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:nil
                        defaultValue:@NO
                              action:ISArgumentParserActionStoreTrue
                         description:@"boolean flag"];
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"--flag"]];
    XCTAssertEqualObjects(options, @{@"flag": @YES}, @"Unexpected argument results.");
}

- (void)testBooleanFlagWithDefaultUnset
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:nil
                        defaultValue:@NO
                              action:ISArgumentParserActionStoreTrue
                         description:@"boolean flag"];
    NSDictionary *options = [self.parser parseArguments:@[@"application"]];
    XCTAssertEqualObjects(options, @{@"flag": @NO}, @"Unexpected argument results.");
}

- (void)testBooleanFlagWithAlternativeSet
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:@"-f"
                        defaultValue:nil
                              action:ISArgumentParserActionStoreTrue
                         description:@"boolean flag"];
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"-f"]];
    XCTAssertEqualObjects(options, @{@"flag": @YES}, @"Unexpected argument results.");
}

- (void)testBooleanFlagWithAlternativeUnset
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:@"-f"
                        defaultValue:nil
                              action:ISArgumentParserActionStoreTrue
                         description:@"boolean flag"];
    NSDictionary *options = [self.parser parseArguments:@[@"application"]];
    XCTAssertEqualObjects(options, @{}, @"Unexpected argument results.");
}

- (void)testOptionalArgument
{
    [self.parser addArgumentWithName:@"--optional"
                     alternativeName:nil
                        defaultValue:nil
                              action:ISArgumentParserActionStore
                         description:@"some optional argument"];
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"--optional", @"value"]];
    NSDictionary *expected = @{@"optional": @"value"};
    XCTAssertEqualObjects(options, expected, @"Unexpected argument results");
    [self.parser help];
}

- (void)testHelp
{
    [self.parser addArgumentWithName:@"url"
                     alternativeName:nil
                        defaultValue:nil
                              action:ISArgumentParserActionStore
                         description:@"the url to download"];
    [self.parser help];
}

@end
