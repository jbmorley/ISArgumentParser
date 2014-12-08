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

#import "ISArgument.h"

NSString *const ISArgumentName = @"name";
NSString *const ISArgumentAlternativeName = @"alternativeName";
NSString *const ISArgumentAction = @"action";
NSString *const ISArgumentNumber = @"number";
NSString *const ISArgumentConstValue = @"constValue";
NSString *const ISArgumentDefaultValue = @"defaultValue";
NSString *const ISArgumentType = @"type";
NSString *const ISArgumentChoices = @"choices";
NSString *const ISArgumentRequired = @"required";
NSString *const ISArgumentHelp = @"help";
NSString *const ISArgumentMetavar = @"metavar";
NSString *const ISArgumentDest = @"dest";

@interface ISArgument ()

@property (nonatomic, readonly, strong) NSArray *choices;
@property (nonatomic, readonly, assign) BOOL required;
@property (nonatomic, readonly, strong) NSString *metavar;
@property (nonatomic, readonly, strong) NSString *dest;

@property (nonatomic, readonly, strong) NSCharacterSet *prefixCharacters;

@end

@implementation ISArgument

+ (instancetype)argumentWithDictionary:(NSDictionary *)dictionary
                      prefixCharacters:(NSCharacterSet *)prefixCharacters
{
    ISArgumentParserAction action = dictionary[ISArgumentAction] ? [dictionary[ISArgumentAction] integerValue] : ISArgumentParserActionStore;
    ISArgumentParserNumber number = dictionary[ISArgumentNumber] ? [dictionary[ISArgumentNumber] integerValue] : ISArgumentParserNumberDefault;
    ISArgumentParserType type = dictionary[ISArgumentType] ? [dictionary[ISArgumentType] integerValue] : ISArgumentParserTypeString;
    BOOL required = dictionary[ISArgumentRequired] ? [dictionary[ISArgumentRequired] boolValue] : NO;
    ISArgument *argument = [[ISArgument alloc] initWithName:dictionary[ISArgumentName]
                                            alternativeName:dictionary[ISArgumentAlternativeName]
                                                     action:action
                                                     number:number
                                                 constValue:dictionary[ISArgumentConstValue]
                                               defaultValue:dictionary[ISArgumentDefaultValue]
                                                       type:type
                                                    choices:dictionary[ISArgumentChoices]
                                                   required:required
                                                       help:dictionary[ISArgumentHelp]
                                                    metavar:dictionary[ISArgumentMetavar]
                                                       dest:dictionary[ISArgumentDest]
                                           prefixCharacters:prefixCharacters];
    return argument;
}

- (instancetype)initWithName:(NSString *)name
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
            prefixCharacters:(NSCharacterSet *)prefixCharacters
{
    self = [super init];
    if (self) {
        _name = name;
        _alternativeName = alternativeName;
        _action = action;
        _number = number;
        _constValue = constValue;
        _defaultValue = defaultValue;
        _type = type;
        _choices = choices;
        _required = required;
        _help = help;
        _metavar = metavar;
        _dest = dest;
        _prefixCharacters = prefixCharacters;
        
        // Check the name.
        if (_name == nil) {
            @throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];
        }
        
        // Determine whether the argument is an option or not.
        NSRange prefixRange = [self.name rangeOfCharacterFromSet:self.prefixCharacters];
        _isOption = (prefixRange.location == 0);
        
        // Alternative names are only valid with options.
        if (!_isOption && _alternativeName != nil) {
            @throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];
        }
        
        // Check that the default and the const value are of the correct type.
        [self assertValue:_defaultValue isNilOrType:type];
        [self assertValue:_constValue isNilOrType:type];
        
    }
    return self;
}

- (void)assertValue:(id)value class:(Class)class
{
    if (![value isKindOfClass:class]) {
        @throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];
    }
}

- (void)assertValue:(id)value isNilOrType:(ISArgumentParserType)type
{
    if (value == nil) {
        return;
    }
    
    if (type == ISArgumentParserTypeString) {
        [self assertValue:value class:[NSString class]];
    }
}

- (NSString *)nameWithoutPrefix
{
    NSString *nameWithoutPrefix = [self stripPrefixes:self.name];
    NSString *alternativeNameWithoutPrefix = [self stripPrefixes:self.alternativeName];
    NSUInteger namePrefixLength = [self.name length] - [nameWithoutPrefix length];
    NSUInteger alternativeNamePrefixLength = [self.alternativeName length] - [alternativeNameWithoutPrefix length];
    if (namePrefixLength >= alternativeNamePrefixLength) {
        return nameWithoutPrefix;
    } else {
        return alternativeNameWithoutPrefix;
    }
}

- (NSString *)destination
{
    if (self.dest) {
        return self.dest;
    } else {
        return [self nameWithoutPrefix];
    }
}

- (NSString *)summaryDefinition
{
    if (self.isOption) {
        
        if (self.action == ISArgumentParserActionStore) {
            return [NSString stringWithFormat:@"[%@ %@]", self.name, [[self nameWithoutPrefix] uppercaseString]];
        } else {
            return [NSString stringWithFormat:@"[%@]", self.name];
        }
        
    } else {
        
        if (self.number == ISArgumentParserNumberDefault) {
            return [self name];
        } else if (self.number == ISArgumentParserNumberOneOrMore) {
            return [NSString stringWithFormat:@"%@ [%@ ...]", [self name], [self name]];
        } else if (self.number == ISArgumentParserNumberZeroOrOne) {
            return [NSString stringWithFormat:@"[%@]", [self name]];
        } else {
            ISAssertUnreached(@"Unsupported number of arguments.");
        }
        
    }
    
    return nil;
}

- (NSString *)stripPrefixes:(NSString *)string
{
    NSString *result = [string copy];
    NSRange prefixRange = [result rangeOfCharacterFromSet:self.prefixCharacters];
    while (prefixRange.location == 0 && prefixRange.length > 0) {
        result = [result substringFromIndex:prefixRange.location + 1];
        prefixRange = [result rangeOfCharacterFromSet:self.prefixCharacters];
    }
    return result;
}

- (NSString *)helpDefinitionForFlag:(NSString *)flag
{
    if (self.action == ISArgumentParserActionStore) {
        return [NSString stringWithFormat:@"%@ %@", flag, [[self stripPrefixes:flag] uppercaseString]];
    } else {
        return [NSString stringWithFormat:@"%@", flag];
    }
}

- (NSString *)helpDefinition
{
    if (self.isOption) {
        NSMutableString *definition = [NSMutableString stringWithString:[self helpDefinitionForFlag:self.name]];
        if (self.alternativeName) {
            [definition appendFormat:@", %@", [self helpDefinitionForFlag:self.alternativeName]];
        }
        return definition;
    } else {
        return self.name;
    }
}

@end
