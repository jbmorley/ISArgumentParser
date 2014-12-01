//
// Copyright (c) 2013-2014 InSeven Limited.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import <ISUtilities/ISUtilities.h>

#import "ISArgumentParser.h"
#import "ISArgument.h"

NSString *const ISArgumentParserErrorDomain = @"ISArgumentParserErrorDomain";

@interface ISArgumentParser ()

@property (nonatomic, readonly, copy) NSString *description;
@property (nonatomic, readonly, strong) NSMutableArray *allArguments;
@property (nonatomic, readonly, strong) NSMutableArray *positionalArguments;
@property (nonatomic, readonly, strong) NSMutableDictionary *optionalArguments;
@property (nonatomic, readonly, strong) NSMutableArray *options;

@end

@implementation ISArgumentParser

+ (NSArray *)argumentsWithCount:(int)count vector:(const char **)vector
{
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        const char *arg = vector[i];
        NSString *argument = [NSString stringWithUTF8String:arg];
        [arguments addObject:argument];
    }
    return arguments;
}

+ (instancetype)argumentParserWithDescription:(NSString *)description
{
    return [[ISArgumentParser alloc] initWithDescription:description];
}

- (instancetype)initWithDescription:(NSString *)description
{
    self = [super init];
    if (self) {
        _description = description;
        _allArguments = [NSMutableArray array];
        _positionalArguments = [NSMutableArray array];
        _optionalArguments = [NSMutableDictionary dictionary];
        _options = [NSMutableArray array];
        _prefixCharacters = @"-";
        
        [self addArgumentWithName:@"--help"
                  alternativeName:@"-h"
                             type:ISArgumentParserTypeBool
                     defaultValue:@(NO)
                           action:ISArgumentParserActionStoreTrue
                      description:@"show this message and exit"];
    }
    return self;
}

- (void)addArgumentWithName:(NSString *)name
                description:(NSString *)description
{
    [self addArgumentWithName:name
              alternativeName:nil
                         type:ISArgumentParserTypeString
                 defaultValue:nil
                       action:ISArgumentParserActionStore
                  description:description];
}

- (void)addArgumentWithName:(NSString *)name
                       type:(ISArgumentParserType)type
                description:(NSString *)description
{
    [self addArgumentWithName:name
              alternativeName:nil
                         type:type
                 defaultValue:nil
                       action:ISArgumentParserActionStore
                  description:description];
}

- (void)addArgumentWithName:(NSString *)name
            alternativeName:(NSString *)alternativeName
                       type:(ISArgumentParserType)type
               defaultValue:(id)defaultValue
                     action:(ISArgumentParserAction)action
                description:(NSString *)description
{
    // Construct the argument.
    ISArgument *argument = [[ISArgument alloc] initWithName:name
                                            alternativeName:alternativeName
                                                       type:type
                                               defaultValue:defaultValue
                                                     action:action
                                                description:description];
    
    // TODO Check the validity of the argument.
    
    // TODO Check for name clashes. Especially between positional and non positional arguments.
    
    // Determine the type of the argument by checking if it begins with a prefix.
    NSArray *prefixes = [self.prefixCharacters componentsSeparatedByString:@""];
    BOOL optional = NO;
    for (NSString *prefix in prefixes) {
        NSRange prefixRange = [argument.name rangeOfString:prefix];
        if (prefixRange.location == 0) {
            optional = YES;
            break;
        }
    }
    
    [self.allArguments addObject:argument];

    // Store the argument.
    if (optional) {
        
        // TODO Check for duplicate arguments.
        
        self.optionalArguments[argument.name] = argument;
        if (argument.alternativeName) {
            self.optionalArguments[argument.alternativeName] = argument;
        }
        
        [self.options addObject:argument];
        
    } else {
        
        [self.positionalArguments addObject:argument];
        
    }

}

- (NSArray *)characters:(NSString *)string
{
    NSMutableArray *characters = [NSMutableArray arrayWithCapacity:[string length]];
    for (NSUInteger i = 0; i < [string length]; i++) {
        unichar character = [string characterAtIndex:i];
        [characters addObject:[NSString stringWithCharacters:&character length:1]];
    }
    return characters;
}

- (NSString *)removePrefixesFromOptionWithName:(NSString *)name
{
    NSSet *prefixes = [NSSet setWithArray:[self.prefixCharacters componentsSeparatedByString:@""]];
    NSMutableArray *characters = [[self characters:name] mutableCopy];
    while ([characters count] > 0) {
        NSString *character = [characters objectAtIndex:0];
        if (![prefixes containsObject:character]) {
            break;
        }
        [characters removeObjectAtIndex:0];
    }
    return [characters componentsJoinedByString:@""];
}

- (NSDictionary *)parseArguments:(NSArray *)arguments error:(NSError *__autoreleasing *)error
{
    NSString *application = [[arguments[0] lastPathComponent] stringByDeletingPathExtension];
    
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    
    // Pre-seed the options with any default values.
    // These will be replaced when we parse the arguments themselves.
    for (ISArgument *argument in self.allArguments) {
        if (argument.defaultValue != nil) {
            options[[self removePrefixesFromOptionWithName:argument.name]] = argument.defaultValue;
        }
    }
    
    // Reverse the arguments to allow us to use the removeLastObject selector.
    NSMutableArray *remainingArguments = [arguments mutableCopy];
    NSMutableArray *positionalArguments = [NSMutableArray array];
    
    // Remove the application name from the arguments.
    [remainingArguments removeObjectAtIndex:0];
    
    const int StateScanning = 0;
    const int StateExpectSingle = 1;
    
    ISArgument *activeOption = nil;
    NSString *activeName = nil;
    
    int state = StateScanning;

    while ([remainingArguments count] > 0) {
        
        // Pop an argument.
        NSString *argument = [remainingArguments firstObject];
        [remainingArguments removeObjectAtIndex:0];
        
        switch (state) {
                
            case StateScanning: {
                
                ISArgument *option = self.optionalArguments[argument];
                if (option) {
                    
                    NSString *name = [self removePrefixesFromOptionWithName:option.name];
                    
                    if (option.action == ISArgumentParserActionStore) {
                        
                        activeOption = option;
                        activeName = name;
                        state = StateExpectSingle;
                        
                    } else if (option.action == ISArgumentParserActionStoreTrue) {
                        
                        options[name] = @YES;
                        state = StateScanning;
                        
                    } else if (option.action == ISArgumentParserActionStoreFalse) {
                        
                        options[name] = @NO;
                        state = StateScanning;
                        
                    } else {
                        
                        fprintf(stderr,
                                "%s: error: unsupported option '%s'\n",
                                [application UTF8String],
                                [argument UTF8String]);
                        if (error) {
                            *error = [NSError errorWithDomain:ISArgumentParserErrorDomain
                                                         code:ISArgumentParserErrorUnsupportedOption
                                                     userInfo:nil];
                        }
                        return nil;
                        
                    }
                    
                } else {
                    
                    [positionalArguments addObject:argument];
                    state = StateScanning;
                    
                }
                
                break;
            }
            case StateExpectSingle: {
                
                options[activeName] = argument;
                activeOption = nil;
                activeName = nil;
                state = StateScanning;
                
                break;
            }
                
        }
        
        // TODO Check that the invariants hold at the end of the loop.
        
    }
    
    ISAssert(state == StateScanning, @"Expecting more arguments :(");
    if (state != StateScanning) {
        fprintf(stderr, "%s: error: invalid arguments\n", [application UTF8String]);
        if (error) {
            *error = [NSError errorWithDomain:ISArgumentParserErrorDomain
                                         code:ISArgumentParserErrorInvalidArguments
                                     userInfo:nil];
        }
        return nil;
    }
    
    // Check to see if the user has asked for help.
    if ([options[@"help"] boolValue]) {
        [self help:application];
        return nil;
    }
    
    // Help is a special key so once we've processed it we remove it from the options.
    [options removeObjectForKey:@"help"];

    // Process the remaining positional arguments.
    
    // TODO Support optional positional arguments.
    
    // Check if there are too few positional arguments.
    if ([positionalArguments count] < [self.positionalArguments count]) {
        fprintf(stderr, "%s: error: too few arguments\n", [application UTF8String]);
        if (error) {
            *error = [NSError errorWithDomain:ISArgumentParserErrorDomain
                                         code:ISArgumentParserErrorTooFewArguments
                                     userInfo:nil];
        }
        return nil;
    }
    
    // Process he positional arguments.
    [self.positionalArguments enumerateObjectsUsingBlock:^(ISArgument *positional, NSUInteger idx, BOOL *stop) {
        options[positional.name] = positionalArguments[0];
        [positionalArguments removeObjectAtIndex:0];
    }];
    
    // Check if there are unrecognized positional argumnets.
    if ([positionalArguments count] > 0) {
        fprintf(stderr, "%s: error: unrecognized arguments: %s\n",
                [application UTF8String],
                [[positionalArguments componentsJoinedByString:@" "] UTF8String]);
        if (error) {
            *error = [NSError errorWithDomain:ISArgumentParserErrorDomain
                                         code:ISArgumentPArserErrorUnrecognizedArguments
                                     userInfo:nil];
        }
        return nil;
    }
    
    return options;
}

- (NSString *)usage:(NSString *)application
{
    NSMutableArray *options = [NSMutableArray arrayWithCapacity:[self.optionalArguments count]];
    
    for (ISArgument *argument in self.options) {
        NSString *option = argument.alternativeName ? : argument.name;
        [options addObject:[NSString stringWithFormat:@"[%@]", option]];
    }
    
    for (ISArgument *argument in self.positionalArguments) {
        [options addObject:argument.name];
    }
    
    NSString *usage = [NSString stringWithFormat:@"usage: %@ %@", application, [options componentsJoinedByString:@" "]];
    
    return usage;
}

- (void)help:(NSString *)application
{
    NSMutableArray *options = [NSMutableArray array];
    for (ISArgument *argument in self.options) {
        [options addObject:[argument help]];
    }

    NSMutableArray *positionals = [NSMutableArray array];
    for (ISArgument *argument in self.positionalArguments) {
        [positionals addObject:[argument help]];
    }
    
    NSString *help = [NSString stringWithFormat:
                      @"%@\n"
                      @"\n"
                      @"%@\n"
                      @"\n"
                      @"positional arguments:\n"
                      @"%@\n"
                      @"\n"
                      @"optional arguments:\n"
                      @"%@\n",
                      [self usage:application],
                      [self description],
                      [positionals componentsJoinedByString:@"\n"],
                      [options componentsJoinedByString:@"\n"]];
    
    printf("%s\n", [help UTF8String]);
}

- (NSDictionary *)parseArgumentsWithCount:(int)count
                                   vector:(const char **)vector
                                    error:(NSError *__autoreleasing *)error
{
    NSArray *arguments = [ISArgumentParser argumentsWithCount:count vector:vector];
    return [self parseArguments:arguments error:error];
}

@end
