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

@interface NSMutableArray (ISUtilities)

- (id)pop;
- (void)removeFirstObject;

@end

@implementation NSMutableArray (ISUtilities)

- (id)pop
{
    id item = [self objectAtIndex:0];
    [self removeFirstObject];
    return item;
}

- (void)removeFirstObject
{
    [self removeObjectAtIndex:0];
}

@end

NSString *const ISArgumentParserErrorDomain = @"ISArgumentParserErrorDomain";

@interface ISArgumentParser ()

@property (nonatomic, readonly, copy) NSString *description;
@property (nonatomic, readonly, strong) NSMutableArray *allArguments;
@property (nonatomic, readonly, strong) NSMutableArray *positionalArguments;
@property (nonatomic, readonly, strong) NSMutableDictionary *optionalArguments;
@property (nonatomic, readonly, strong) NSMutableArray *options;

/**
 * Set for tracking the requested argument destinations.
 * 
 * When new arguments are added we should check that their requested destination doesn't already exist.
 */
@property (nonatomic, readonly, strong) NSMutableSet *destinations;

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
        _destinations = [NSMutableSet set];
        _prefixCharacters = @"-";
        
        [self addArgumentWithName:@"-h"
                  alternativeName:@"--help"
                           action:ISArgumentParserActionStoreTrue
                           number:ISArgumentParserNumberDefault
                       constValue:nil
                     defaultValue:@NO
                             type:ISArgumentParserTypeBool
                          choices:nil
                         required:YES
                             help:@"show this message and exit"
                          metavar:nil
                             dest:@"help"];
    }
    return self;
}

- (void)addArgumentWithName:(NSString *)name
                       help:(NSString *)help
{
    [self addArgumentWithName:name
              alternativeName:nil
                       action:ISArgumentParserActionStore
                       number:ISArgumentParserNumberDefault
                   constValue:nil
                 defaultValue:nil
                         type:ISArgumentParserTypeString
                      choices:nil
                     required:YES
                         help:help
                      metavar:nil
                         dest:nil];
}

- (void)addArgumentWithName:(NSString *)name
                       type:(ISArgumentParserType)type
                       help:(NSString *)help
{
    [self addArgumentWithName:name
              alternativeName:nil
                       action:ISArgumentParserActionStore
                       number:ISArgumentParserNumberDefault
                   constValue:nil
                 defaultValue:nil
                         type:type
                      choices:nil
                     required:YES
                         help:help
                      metavar:nil
                         dest:nil];
}

- (void)addArgumentWithDictionary:(NSDictionary *)dictionary
{
    ISArgumentParserAction action = dictionary[@"action"] ? [dictionary[@"action"] integerValue] : ISArgumentParserActionStore;
    ISArgumentParserNumber number = dictionary[@"number"] ? [dictionary[@"number"] integerValue] : ISArgumentParserNumberDefault;
    ISArgumentParserType type = dictionary[@"type"] ? [dictionary[@"type"] integerValue] : ISArgumentParserTypeString;
    BOOL required = dictionary[@"required"] ? [dictionary[@"required"] boolValue] : NO;
    NSCharacterSet *prefixCharacters = [NSCharacterSet characterSetWithCharactersInString:self.prefixCharacters];
    ISArgument *argument = [[ISArgument alloc] initWithName:dictionary[@"name"]
                                            alternativeName:dictionary[@"alternativeName"]
                                                     action:action
                                                     number:number
                                                 constValue:dictionary[@"constValue"]
                                               defaultValue:dictionary[@"defaultValue"]
                                                       type:type
                                                    choices:dictionary[@"choices"]
                                                   required:required
                                                       help:dictionary[@"help"]
                                                    metavar:dictionary[@"metavar"]
                                                       dest:dictionary[@"dest"]
                                           prefixCharacters:prefixCharacters];
    [self addArgument:argument];
}

- (void)registerArgument:(ISArgument *)argument
                 forFlag:(NSString *)flag
{
    ISArgument *existing = self.optionalArguments[flag];
    if (existing) {
        @throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];
    }
    self.optionalArguments[flag] = argument;
}

- (void)addArgumentWithName:(NSString *)name
            alternativeName:(NSString *)alternativeName
                     action:(ISArgumentParserAction)action
               defaultValue:(id)defaultValue
                       type:(ISArgumentParserType)type
                       help:(NSString *)help
{
    [self addArgumentWithName:name
              alternativeName:alternativeName
                       action:action
                       number:ISArgumentParserNumberDefault
                   constValue:nil
                 defaultValue:defaultValue
                         type:type
                      choices:nil
                     required:YES
                         help:help
                      metavar:nil
                         dest:nil];
}

- (void)addArgumentWithName:(NSString *)name
            alternativeName:(NSString *)alternativeName
                     action:(ISArgumentParserAction)action
                     number:(ISArgumentParserNumber)number
                 constValue:(id)constValue
               defaultValue:(id)defaultValue
                       type:(ISArgumentParserType)type
                    choices:(NSArray *)choices
                   required:(BOOL)required
                       help:(NSString *)help
                    metavar:(NSString *)metavar
                       dest:(NSString *)dest
{
    // Construct the argument.
    NSCharacterSet *prefixCharacters = [NSCharacterSet characterSetWithCharactersInString:self.prefixCharacters];
    ISArgument *argument = [[ISArgument alloc] initWithName:name
                                            alternativeName:alternativeName
                                                     action:action
                                                     number:number
                                                 constValue:constValue
                                               defaultValue:defaultValue
                                                       type:type
                                                    choices:choices
                                                   required:required
                                                       help:help
                                                    metavar:metavar
                                                       dest:dest
                                           prefixCharacters:prefixCharacters];
    
    [self addArgument:argument];
}

- (void)addArgument:(ISArgument *)argument
{
    
    // Check that the argument destination doesn't already exist.
    if ([self.destinations containsObject:[argument destination]]) {
        @throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];
    }
    
    // Add the argument to the list of all arguments.
    [self.allArguments addObject:argument];

    // Store the argument.
    if (argument.isOption) {
        [self registerArgument:argument forFlag:argument.name];
        if (argument.alternativeName) {
            [self registerArgument:argument forFlag:argument.alternativeName];
        }
        [self.options addObject:argument];
    } else {
        [self.positionalArguments addObject:argument];
    }

}

- (NSDictionary *)parseArguments:(NSArray *)arguments error:(NSError *__autoreleasing *)error
{
    NSString *application = [[arguments[0] lastPathComponent] stringByDeletingPathExtension];
    
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    
    // Pre-seed the options with any default values.
    // These will be replaced when we parse the arguments themselves.
    for (ISArgument *argument in self.allArguments) {
        if (argument.defaultValue != nil) {
            options[[argument destination]] = argument.defaultValue;
        }
    }
    
    // Reverse the arguments to allow us to use the removeLastObject selector.
    NSMutableArray *remainingArguments = [arguments mutableCopy];
    NSMutableArray *positionalArguments = [NSMutableArray array];
    
    // Remove the application name from the arguments.
    [remainingArguments removeFirstObject];
    
    
    NSUInteger positionalIndex = 0;
    while ([remainingArguments count] > 0) {
        
        NSString *value = [remainingArguments firstObject];
        
        // Find an argument to process the current value.
        ISArgument *argument = [self optionalArgumentForFlag:value];
        if (argument == nil &&
            positionalIndex < [self.positionalArguments count]) {
            argument = self.positionalArguments[positionalIndex];
            positionalIndex++;
        }
        
        if (argument == nil) {
            break;
        }
        
        [self processArguments:remainingArguments
                 usingArgument:argument
                       options:options];
    }
    
    // Check to see if the user has asked for help.
    if ([options[@"help"] boolValue]) {
        [self printHelp:application];
        return nil;
    }
    
    // Help is a special key so once we've processed it we remove it from the options.
    [options removeObjectForKey:@"help"];

    // Process the remaining positional arguments.
    
    // TODO Support optional positional arguments.
    
    // Check if there are too few positional arguments.
    if (positionalIndex < [self.positionalArguments count]) {
        
        // Ensure that any remaining arguments are optional.
        BOOL optional = YES;
        for (NSUInteger i = positionalIndex; i < [self.positionalArguments count]; i++) {
            ISArgument *argument = self.positionalArguments[i];
            optional &= (argument.number == ISArgumentParserNumberZeroOrOne ||
                         argument.number == ISArgumentParserNumberRemainder ||
                         argument.number == ISArgumentParserNumberAll);
        }
        
        if (!optional) {
        
            [self printUsage:application];
            fprintf(stderr, "%s: error: too few arguments\n", [application UTF8String]);
            if (error) {
                *error = [NSError errorWithDomain:ISArgumentParserErrorDomain
                                             code:ISArgumentParserErrorTooFewArguments
                                         userInfo:nil];
            }
            return nil;
            
        }
        
    } else if ([remainingArguments count] > 0) {

        [self printUsage:application];
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

- (ISArgument *)optionalArgumentForFlag:(NSString *)flag
{
    return self.optionalArguments[flag];
}

- (BOOL)isFlag:(NSString *)string
{
    return (self.optionalArguments[string] != nil);
}

- (void)processArguments:(NSMutableArray *)arguments
           usingArgument:(ISArgument *)argument
                 options:(NSMutableDictionary *)options
{
    
    if (argument.isOption) {
        [arguments removeFirstObject];
    }
    
    NSString *destination = [argument destination];
    
    if (argument.number == ISArgumentParserNumberOneOrMore) {
        
        options[destination] = [NSMutableArray array];
        [options[destination] addObject:[arguments pop]];
        while ([arguments count] > 0) {
            NSString *value = [arguments firstObject];
            if ([self isFlag:value]) {
                return;
            }
            [options[destination] addObject:[arguments pop]];
        }
        
        
    } else if (argument.number == ISArgumentParserNumberDefault) {
        
        if (argument.action == ISArgumentParserActionStore) {
            
            NSString *value = [arguments pop];
            options[destination] = value;
            
        } else if (argument.action == ISArgumentParserActionStoreTrue) {
            
            options[destination] = @YES;
            
        } else if (argument.action == ISArgumentParserActionStoreFalse) {
            
            options[destination] = @NO;
            
        }
        
    } else {
        
        // The number is specific so we must capture that number of arguments.
        options[destination] = [NSMutableArray array];
        for (NSUInteger i = 0; i < argument.number; i++) {
            [options[destination] addObject:[arguments pop]];
        }
        
    }
    
}

- (NSString *)usage
{
    return [self usage:nil];
}

- (void)printUsage
{
    [self printUsage:nil];
}

- (void)printUsage:(NSString *)application
{
    NSString *usage = [self usage:application];
    printf("%s\n", [usage UTF8String]);
}

- (NSString *)usage:(NSString *)application
{
    NSMutableArray *options = [NSMutableArray arrayWithCapacity:[self.optionalArguments count]];
    
    NSMutableString *usage = [NSMutableString string];
    [usage appendString:@"usage: "];
    
    if (application) {
        [usage appendFormat:@"%@: ", application];
    }
    
    for (ISArgument *argument in self.options) {
        [options addObject:[argument summaryDefinition]];
    }
    
    for (ISArgument *argument in self.positionalArguments) {
        [options addObject:[argument summaryDefinition]];
    }

        
    [usage appendString:[options componentsJoinedByString:@" "]];
    
    return usage;
}

- (void)printHelp
{
    [self printHelp:nil];
}

- (void)printHelp:(NSString *)application
{
    NSString *help = [self help:application];
    printf("%s\n", [help UTF8String]);
}

- (NSString *)help:(NSString *)application
{
    NSMutableArray *options = [NSMutableArray array];
    for (ISArgument *argument in self.options) {
        [options addObject:[NSString stringWithFormat:@"  %@    %@", [argument helpDefinition], argument.help]];
    }

    NSMutableArray *positionals = [NSMutableArray array];
    for (ISArgument *argument in self.positionalArguments) {
        [positionals addObject:[NSString stringWithFormat:@"  %@    %@", [argument helpDefinition], argument.help]];
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
    
    return help;
}

- (NSDictionary *)parseArgumentsWithCount:(int)count
                                   vector:(const char **)vector
                                    error:(NSError *__autoreleasing *)error
{
    NSArray *arguments = [ISArgumentParser argumentsWithCount:count vector:vector];
    return [self parseArguments:arguments error:error];
}

@end
