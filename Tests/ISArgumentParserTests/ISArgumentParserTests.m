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
                              action:ISArgumentParserActionStore
                        defaultValue:nil
                                type:ISArgumentParserTypeString
                                help:@"first argument"];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"value1"] error:&error];
    XCTAssertEqualObjects(options, @{@"argument1": @"value1"}, @"Unexpected argument results.");
}

- (void)testMultipleArguments
{
    [self.parser addArgumentWithName:@"argument1"
                     alternativeName:nil
                              action:ISArgumentParserActionStore
                        defaultValue:nil
                                type:ISArgumentParserTypeString
                                help:@"first argument"];
    [self.parser addArgumentWithName:@"argument2"
                     alternativeName:nil
                              action:ISArgumentParserActionStore
                        defaultValue:nil
                                type:ISArgumentParserTypeString
                                help:@"second argument"];
    [self.parser addArgumentWithName:@"argument3"
                     alternativeName:nil
                              action:ISArgumentParserActionStore
                        defaultValue:nil
                                type:ISArgumentParserTypeString
                                help:@"third argument"];

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
    [self.parser addArgumentWithDictionary:@{@"name": @"--flag",
                                             @"action": @(ISArgumentParserActionStoreTrue),
                                             @"help": @"boolean flag",
                                             @"type": @(ISArgumentParserTypeBool)}];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"--flag"] error:&error];
    XCTAssertEqualObjects(options, @{@"flag": @YES}, @"Unexpected argument results.");
}

- (void)testBooleanFlagUnset
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:nil
                              action:ISArgumentParserActionStoreTrue
                        defaultValue:nil
                                type:ISArgumentParserTypeBool
                                help:@"boolean flag"];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application"] error:&error];
    XCTAssertEqualObjects(options, @{}, @"Unexpected argument results.");
}

- (void)testBooleanFlagWithDefaultSet
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:nil
                              action:ISArgumentParserActionStoreTrue
                        defaultValue:@NO
                                type:ISArgumentParserTypeBool
                                help:@"boolean flag"];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"--flag"] error:&error];
    XCTAssertEqualObjects(options, @{@"flag": @YES}, @"Unexpected argument results.");
}

- (void)testBooleanFlagWithDefaultUnset
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:nil
                              action:ISArgumentParserActionStoreTrue
                        defaultValue:@NO
                                type:ISArgumentParserTypeBool
                                help:@"boolean flag"];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application"] error:&error];
    XCTAssertEqualObjects(options, @{@"flag": @NO}, @"Unexpected argument results.");
}

- (void)testBooleanFlagWithAlternativeSet
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:@"-f"
                              action:ISArgumentParserActionStoreTrue
                        defaultValue:nil
                                type:ISArgumentParserTypeBool
                                help:@"boolean flag"];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"-f"] error:&error];
    XCTAssertEqualObjects(options, @{@"flag": @YES}, @"Unexpected argument results.");
}

- (void)testBooleanFlagWithAlternativeUnset
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:@"-f"
                              action:ISArgumentParserActionStoreTrue
                        defaultValue:nil
                                type:ISArgumentParserTypeBool
                                help:@"boolean flag"];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application"] error:&error];
    XCTAssertEqualObjects(options, @{}, @"Unexpected argument results.");
}

- (void)testOptionalArgument
{
    [self.parser addArgumentWithName:@"--optional"
                     alternativeName:nil
                              action:ISArgumentParserActionStore
                        defaultValue:nil
                                type:ISArgumentParserTypeString
                                help:@"some optional argument"];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"--optional", @"value"] error:&error];
    NSDictionary *expected = @{@"optional": @"value"};
    XCTAssertEqualObjects(options, expected, @"Unexpected argument results");
    [self.parser printHelp];
}

- (void)testOneOrMoreArguments
{
    [self.parser addArgumentWithDictionary:@{@"name": @"filename",
                                             @"number": @(ISArgumentParserNumberOneOrMore),
                                             @"help": @"boolean flag"}];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"/tmp/file1", @"/tmp/file2"] error:&error];
    NSDictionary *expected = @{@"filename": @[@"/tmp/file1", @"/tmp/file2"]};
    XCTAssertEqualObjects(options, expected, @"Unexpected argument results.");
}

- (void)testOneOrMoreFlags
{
    [self.parser addArgumentWithDictionary:@{@"name": @"--filename",
                                             @"number": @(ISArgumentParserNumberOneOrMore),
                                             @"help": @"boolean flag"}];
    NSError *error = nil;
    NSDictionary *options = [self.parser parseArguments:@[@"application", @"--filename", @"/tmp/file1", @"/tmp/file2"] error:&error];
    NSDictionary *expected = @{@"filename": @[@"/tmp/file1", @"/tmp/file2"]};
    XCTAssertEqualObjects(options, expected, @"Unexpected argument results.");
}

#pragma mark - Usage

- (void)testUsageOneOrMoreArguments
{
    [self.parser addArgumentWithDictionary:@{@"name": @"filename",
                                             @"number": @(ISArgumentParserNumberOneOrMore)}];
    XCTAssertEqualObjects([self.parser usage], @"usage: [-h] filename [filename ...]");
}

- (void)testUsageZeroOrOneArguments
{
    [self.parser addArgumentWithDictionary:@{@"name": @"filename",
                                             @"number": @(ISArgumentParserNumberZeroOrOne)}];
    XCTAssertEqualObjects([self.parser usage], @"usage: [-h] [filename]");
}

- (void)testHelp
{
    [self.parser addArgumentWithName:@"url"
                     alternativeName:nil
                              action:ISArgumentParserActionStore
                        defaultValue:nil
                                type:ISArgumentParserTypeString
                                help:@"the url to download"];
    [self.parser printHelp];
}

- (void)testUsageOrdering
{
    [self.parser addArgumentWithName:@"positional"
                     alternativeName:nil
                              action:ISArgumentParserActionStore
                        defaultValue:nil
                                type:ISArgumentParserTypeString
                                help:@"a positional argument"];
    [self.parser addArgumentWithName:@"--option"
                     alternativeName:@"-o"
                              action:ISArgumentParserActionStore
                        defaultValue:nil
                                type:ISArgumentParserTypeString
                                help:@"an optional argument"];
    XCTAssertEqualObjects([self.parser usage], @"usage: [-h] [--option OPTION] positional");
}

@end
