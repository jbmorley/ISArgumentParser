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

@interface ISArgument ()

@end

@implementation ISArgument

- (instancetype)initWithName:(NSString *)name
             alternativeName:(NSString *)alternativeName
                        type:(ISArgumentParserType)type
                defaultValue:(id)defaultValue
                      action:(ISArgumentParserAction)action
                 description:(NSString *)description
{
    self = [super init];
    if (self) {
        _name = name;
        _alternativeName = alternativeName;
        _type = type;
        _defaultValue = defaultValue;
        _action = action;
        _description = description;
        
        // Check that the defualt value is of the correct type if one is set.
        if (_defaultValue) {
            if (_type == ISArgumentParserTypeString) {
                ISAssert([_defaultValue isKindOfClass:[NSString class]], @"Default argument isn't of type NSString.");
            } else if (_type == ISArgumentParserTypeInteger ||
                       _type == ISArgumentParserTypeBool) {
                ISAssert([_defaultValue isKindOfClass:[NSNumber class]], @"Default argument isn't of type NSNumber.");
            } else {
                ISAssertUnreached(@"Unknown type (%d).", _type);
            }
        }
        
    }
    return self;
}

- (NSString *)help
{
    NSMutableString *help = [NSMutableString string];
    [help appendString:@"  "];
    [help appendString:self.name];
    if (self.alternativeName) {
        [help appendString:@", "];
        [help appendString:self.alternativeName];
    }
    [help appendString:@"  "];
    [help appendString:self.description];
    return help;
}

- (NSString *)shortOptionString
{
    if (self.action == ISArgumentParserActionStore) {
        return [NSString stringWithFormat:@"[%@ %@]", self.name, [self.name uppercaseString]];
    } else {
        return [NSString stringWithFormat:@"[%@]", self.name];
    }
}

@end
