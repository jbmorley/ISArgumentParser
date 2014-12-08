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

- (NSDictionary *)parseArguments:(NSString *)string error:(NSError *__autoreleasing *)error
{
    NSMutableArray *arguments = [NSMutableArray array];
    [arguments addObject:@"application"];
    if ([string length] > 0) {
        [arguments addObjectsFromArray:[string componentsSeparatedByString:@" "]];
    }
    return [self.parser parseArguments:arguments error:error];
}

- (NSDictionary *)assertParseArguments:(NSString *)arguments
                       expectedOptions:(NSDictionary *)expectedOptions
{
    NSDictionary *options = [self parseArguments:arguments error:NULL];
    XCTAssertEqualObjects(options, expectedOptions, @"Unexpected argument results.");
}

- (NSDictionary *)assertParseArguments:(NSString *)arguments
                     expectedErrorCode:(ISArgumentParserError)expectedErrorCode
{
    NSError *error = nil;
    NSDictionary *options = [self parseArguments:arguments error:&error];
    XCTAssertNil(options);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, ISArgumentParserErrorDomain);
    XCTAssertEqual(error.code, expectedErrorCode);
}

- (void)testSingleArgument
{
    [self.parser addArgumentWithName:@"argument1"
                     alternativeName:nil
                              action:ISArgumentParserActionStore
                        defaultValue:nil
                                type:ISArgumentParserTypeString
                                help:@"first argument"];
    [self assertParseArguments:@"value1" expectedOptions:@{@"argument1": @"value1"}];
}

- (void)testMultipleArguments
{
    [self.parser addArgumentWithName:@"argument1"
                                help:@"first argument"];
    [self.parser addArgumentWithName:@"argument2"
                                help:@"second argument"];
    [self.parser addArgumentWithName:@"argument3"
                                help:@"third argument"];
    [self assertParseArguments:@"value1 value2 value3"
               expectedOptions:@{@"argument1": @"value1", @"argument2": @"value2", @"argument3": @"value3"}];
}

- (void)testPrefixCharacters
{
    self.parser.prefixCharacters = @"-+";
    [self.parser addArgumentWithName:@"+f"];
    [self.parser addArgumentWithName:@"++bar"];
    [self assertParseArguments:@"+f X ++bar Y"
               expectedOptions:@{@"bar": @"Y", @"f": @"X"}];
}

- (void)testArgumentWithAlternativeNameFails
{
    XCTAssertThrows([self.parser addArgumentWithName:@"name"
                                     alternativeName:@"alternativeName"]);
}

- (void)testOptionalWithAlternativeNameSucceeds
{
    XCTAssertNoThrow([self.parser addArgumentWithName:@"-f" alternativeName:@"--foo"]);
}

- (void)testOptionalAndPositional
{
    [self.parser addArgumentWithName:@"-f" alternativeName:@"--foo"];
    [self.parser addArgumentWithName:@"bar"];
    [self assertParseArguments:@"BAR" expectedOptions:@{@"bar": @"BAR"}];
    [self assertParseArguments:@"BAR --foo FOO" expectedOptions:@{@"bar": @"BAR", @"foo": @"FOO"}];
    [self assertParseArguments:@"--foo FOO"
             expectedErrorCode:ISArgumentParserErrorTooFewArguments];
}

- (void)testActionStore
{
    [self.parser addArgumentWithName:@"--foo"];
    [self assertParseArguments:@"--foo 1"
               expectedOptions:@{@"foo": @"1"}];
}

- (void)testActionStoreConst
{
    [self.parser addArgumentWithName:@"--foo"
                              action:ISArgumentParserActionStoreConst
                          constValue:@"42"];
    [self assertParseArguments:@"--foo" expectedOptions:@{@"foo": @"42"}];
}

- (void)testConstTypeMismatch
{
    XCTAssertThrows([self.parser addArgumentWithName:@"--foo"
                                              action:ISArgumentParserActionStoreConst
                                          constValue:@42]);
}

- (void)testIntergerCoercion
{
    [self.parser addArgumentWithName:@"--foo"
                                type:ISArgumentParserTypeInteger];
    [self assertParseArguments:@"--foo 42" expectedOptions:@{@"foo": @42}];
}

- (void)testBooleanFlagSet
{
    [self.parser addArgumentWithName:@"--flag"
                              action:ISArgumentParserActionStoreTrue
                                type:ISArgumentParserTypeBool
                                help:@"boolean flag"];
    [self assertParseArguments:@"--flag" expectedOptions:@{@"flag": @YES}];
}

- (void)testBooleanFlagUnset
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:nil
                              action:ISArgumentParserActionStoreTrue
                        defaultValue:nil
                                type:ISArgumentParserTypeBool
                                help:@"boolean flag"];
    [self assertParseArguments:@"" expectedOptions:@{}];
}

- (void)testBooleanFlagWithDefaultSet
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:nil
                              action:ISArgumentParserActionStoreTrue
                        defaultValue:@NO
                                type:ISArgumentParserTypeBool
                                help:@"boolean flag"];
    [self assertParseArguments:@"--flag" expectedOptions:@{@"flag": @YES}];
}

- (void)testBooleanFlagWithDefaultUnset
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:nil
                              action:ISArgumentParserActionStoreTrue
                        defaultValue:@NO
                                type:ISArgumentParserTypeBool
                                help:@"boolean flag"];
    [self assertParseArguments:@"" expectedOptions:@{@"flag": @NO}];
}

- (void)testBooleanFlagWithAlternativeSet
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:@"-f"
                              action:ISArgumentParserActionStoreTrue
                        defaultValue:nil
                                type:ISArgumentParserTypeBool
                                help:@"boolean flag"];
    [self assertParseArguments:@"-f" expectedOptions:@{@"flag": @YES}];
}

- (void)testBooleanFlagWithAlternativeUnset
{
    [self.parser addArgumentWithName:@"--flag"
                     alternativeName:@"-f"
                              action:ISArgumentParserActionStoreTrue
                        defaultValue:nil
                                type:ISArgumentParserTypeBool
                                help:@"boolean flag"];
    [self assertParseArguments:@"" expectedOptions:@{}];
}

- (void)testOptionalArgument
{
    [self.parser addArgumentWithName:@"--optional"
                     alternativeName:nil
                              action:ISArgumentParserActionStore
                        defaultValue:nil
                                type:ISArgumentParserTypeString
                                help:@"some optional argument"];
    [self assertParseArguments:@"--optional value" expectedOptions:@{@"optional": @"value"}];
}

- (void)testOneOrMoreArguments
{
    [self.parser addArgumentWithName:@"filename"
                              number:ISArgumentParserNumberOneOrMore
                                help:@"boolean flag"];
    [self assertParseArguments:@"/tmp/file1 /tmp/file2"
               expectedOptions:@{@"filename": @[@"/tmp/file1", @"/tmp/file2"]}];
}

- (void)testOneOrMoreFlags
{
    [self.parser addArgumentWithName:@"--filename"
                              number:ISArgumentParserNumberOneOrMore];
    [self assertParseArguments:@"--filename /tmp/file1 /tmp/file2"
               expectedOptions:@{@"filename": @[@"/tmp/file1", @"/tmp/file2"]}];
}

- (void)testOneOrMoreOptionalArguments
{
    [self.parser addArgumentWithName:@"--foo"
                              number:ISArgumentParserNumberAll];
    [self.parser addArgumentWithName:@"--bar"
                              number:ISArgumentParserNumberAll];
    [self.parser addArgumentWithName:@"baz"
                              number:ISArgumentParserNumberAll];
    [self assertParseArguments:@"a b --foo x y --bar 1 2"
               expectedOptions:@{@"bar": @[@"1", @"2"], @"baz": @[@"a", @"b"], @"foo": @[@"x", @"y"]}];
}

#pragma mark - Usage

- (void)testUsageOneOrMoreArguments
{
    [self.parser addArgumentWithName:@"filename"
                              number:ISArgumentParserNumberOneOrMore];
    XCTAssertEqualObjects([self.parser usage], @"usage: [-h] filename [filename ...]");
}

- (void)testUsageZeroOrOneArguments
{
    [self.parser addArgumentWithName:@"filename"
                              number:ISArgumentParserNumberZeroOrOne];
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
