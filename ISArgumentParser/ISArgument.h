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

#import "ISArgumentParser.h"

extern NSString *const ISArgumentName;
extern NSString *const ISArgumentAlternativeName;
extern NSString *const ISArgumentAction;
extern NSString *const ISArgumentNumber;
extern NSString *const ISArgumentConstValue;
extern NSString *const ISArgumentDefaultValue;
extern NSString *const ISArgumentType;
extern NSString *const ISArgumentChoices;
extern NSString *const ISArgumentRequired;
extern NSString *const ISArgumentHelp;
extern NSString *const ISArgumentMetavar;
extern NSString *const ISArgumentDest;

@interface ISArgument : NSObject

@property (nonatomic, readonly, strong) NSString *name;
@property (nonatomic, readonly, strong) NSString *alternativeName;
@property (nonatomic, readonly, assign) ISArgumentParserAction action;
@property (nonatomic, readonly, assign) ISArgumentParserNumber number;
@property (nonatomic, readonly, strong) id constValue;
@property (nonatomic, readonly, strong) id defaultValue;
@property (nonatomic, readonly, assign) ISArgumentParserType type;
@property (nonatomic, readonly, strong) NSString *help;
@property (nonatomic, readonly, assign) BOOL isOption;

+ (instancetype)new __attribute__((unavailable("new not available")));
- (instancetype)init __attribute__((unavailable("init not available")));

+ (instancetype)argumentWithDictionary:(NSDictionary *)dictionary
                      prefixCharacters:(NSCharacterSet *)prefixCharacters;
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
                        dest:(NSString *)help
            prefixCharacters:(NSCharacterSet *)prefixCharacters;

- (NSString *)destination;

- (NSString *)summaryDefinition;
- (NSString *)helpDefinition;

@end
