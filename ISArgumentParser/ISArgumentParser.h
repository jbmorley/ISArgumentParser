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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ISArgumentParserAction) {
    
    /**
     * This just stores the argument’s value. This is the default action.
     */
    ISArgumentParserActionStore,
    
    /**
     * This stores the value specified by the const keyword argument. (Note that the constValue argument defaults to
     * nil.) This action is most commonly used with optional arguments that specify some sort of flag.
     */
    ISArgumentParserActionStoreConst,
    
    ISArgumentParserActionStoreTrue,
    ISArgumentParserActionStoreFalse,
    
    /**
     * This stores a list, and appends each argument value to the list. This is useful to allow an option to be
     * specified multiple times.
     */
    ISArgumentParserActionAppend,
};

typedef NS_ENUM(NSUInteger, ISArgumentParserType) {
    ISArgumentParserTypeString,
    ISArgumentParserTypeInteger,
    ISArgumentParserTypeBool,
};

extern NSString *const ISArgumentParserErrorDomain;

typedef NS_ENUM(NSUInteger, ISArgumentParserError) {
    ISArgumentParserErrorInvalidArguments,
    ISArgumentParserErrorUnsupportedOption,
    ISArgumentParserErrorTooFewArguments,
    ISArgumentParserErrorUnrecognizedArguments,
};

typedef NS_ENUM(NSUInteger, ISArgumentParserNumber) {
    ISArgumentParserNumberDefault = NSUIntegerMax,
    ISArgumentParserNumberOneOrMore = NSUIntegerMax - 1,
    ISArgumentParserNumberZeroOrOne = NSUIntegerMax - 2,
    ISArgumentParserNumberAll = NSUIntegerMax - 3,
    ISArgumentParserNumberRemainder = NSUIntegerMax - 4,
};

@interface ISArgumentParser : NSObject

@property (nonatomic, readwrite, copy) NSString *prefixCharacters;

+ (instancetype)new __attribute__((unavailable("new not available")));
- (instancetype)init __attribute__((unavailable("init not available")));

+ (instancetype)argumentParserWithDescription:(NSString *)description;
- (instancetype)initWithDescription:(NSString *)description;

- (void)addArgumentWithName:(NSString *)name;
- (void)addArgumentWithName:(NSString *)name
            alternativeName:(NSString *)alternativeName;
- (void)addArgumentWithName:(NSString *)name
                       help:(NSString *)help;
- (void)addArgumentWithName:(NSString *)name
                     number:(ISArgumentParserNumber)number;
- (void)addArgumentWithName:(NSString *)name
                       type:(ISArgumentParserType)type
                       help:(NSString *)help;
- (void)addArgumentWithName:(NSString *)name
                     number:(ISArgumentParserNumber)number
                       help:(NSString *)help;
- (void)addArgumentWithName:(NSString *)name
                     action:(ISArgumentParserAction)action
                 constValue:(id)constValue;
- (void)addArgumentWithName:(NSString *)name
                     action:(ISArgumentParserAction)action
                       type:(ISArgumentParserType)type
                       help:(NSString *)help;
- (void)addArgumentWithName:(NSString *)name
            alternativeName:(NSString *)alternativeName
                     action:(ISArgumentParserAction)action
               defaultValue:(id)defaultValue
                       type:(ISArgumentParserType)type
                       help:(NSString *)help;
- (void)addArgumentWithName:(NSString *)name
            alternativeName:(NSString *)alternativeName
                     action:(ISArgumentParserAction)action
               defaultValue:(id)defaultValue
                       type:(ISArgumentParserType)type
                       help:(NSString *)help
                       dest:(NSString *)dest;

/**
 * @param name or flags - Either a name or a list of option strings, e.g. foo or -f, --foo.
 * @param alternativeName
 * @param action The basic type of action to be taken when this argument is encountered at the command line.
 * @param number The number of command-line arguments that should be consumed.
 * @param constValue A constant value required by some action and nargs selections.
 * @param defaultValue The value produced if the argument is absent from the command line.
 * @param type The type to which the command-line argument should be converted.
 * @param choices A container of the allowable values for the argument.
 * @param required Whether or not the command-line option may be omitted (optionals only).
 * @param help A brief description of what the argument does.
 * @param metavar A name for the argument in usage messages.
 * @param dest The name of the attribute to be added to the object returned by `parseArguments:`.
 */
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
                       dest:(NSString *)dest;

- (NSString *)usage;

- (void)printUsage;
- (void)printHelp;

- (NSDictionary *)parseArguments:(NSArray *)arguments
                           error:(NSError *__autoreleasing *)error;
- (NSDictionary *)parseArgumentsWithCount:(int)count
                                   vector:(const char **)vector
                                    error:(NSError *__autoreleasing *)error;

@end
