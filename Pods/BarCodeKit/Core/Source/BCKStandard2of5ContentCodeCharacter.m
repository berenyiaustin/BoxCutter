//
//  BCKStandard2of5ContentCodeCharacter.m
//  BarCodeKit
//
//  Created by Geoff Breemer on 18/09/13.
//  Copyright (c) 2013 Oliver Drobnik. All rights reserved.
//

#import "BCKStandard2of5ContentCodeCharacter.h"

#define NUMBER_OF_STANDARD2OF5CODE_CHARACTERS 10
#define CHARACTER_DIMENSION 0
#define ENCODING_DIMENSION 1

// Source: http://barcode-coder.com/en/standard-2-of-5-specification-103.html

static char *char_encodings[NUMBER_OF_STANDARD2OF5CODE_CHARACTERS][2] = {
	{"0", "1010111011101"},
	{"1", "1110101010111"},
	{"2", "1011101010111"},
	{"3", "1110111010101"},
	{"4", "1010111010111"},
	{"5", "1110101110101"},
	{"6", "1011101110101"},
	{"7", "1010101110111"},
	{"8", "1110101011101"},
	{"9", "1011101011101"}};

@implementation BCKStandard2of5ContentCodeCharacter
{
	NSString *_character;
}

// Initialise the code character using its value. Only values for numeric characters are valid.
// For example: to initialise the code character with an 1 initialise it by passing the value 1
- (instancetype)initWithCharacterValue:(NSUInteger)characterValue
{
	self = [super init];
	
	if (self)
	{
		if (characterValue >= NUMBER_OF_STANDARD2OF5CODE_CHARACTERS)
		{
			return nil;
		}
		else
		{
			_character = [NSString stringWithUTF8String:char_encodings[characterValue][CHARACTER_DIMENSION]];
		}
	}
	
	return self;
}

// Initialise the code character using its value. Only values for numeric characters and the dash character are valid.
// For example: to initialise the code character with an 1 initialise it by passing the value 1
- (instancetype)initWithCharacterValue:(NSUInteger)characterValue isCheckDigit:(BOOL)isCheckDigit
{
	self = [super init];
	
	if (self)
	{
		if (characterValue >= NUMBER_OF_STANDARD2OF5CODE_CHARACTERS)
		{
			return nil;
		}
		else
		{
			_character = [NSString stringWithUTF8String:char_encodings[characterValue][CHARACTER_DIMENSION]];
		}
	}
	
	return self;
}

- (instancetype)initWithCharacter:(NSString *)character
{
	self = [super init];
	
	if (self)
	{
		if (![self _encodingForCharacter:character])
		{
			return nil;
		}
		
		_character = [character copy];
	}
	
	return self;
}

// Returns the character's value by returning its index in the char_encodings array. For example: the 2 is the second character in the array so this method returns the value 2
- (NSUInteger)characterValue
{
	const char *searchChar = [_character UTF8String];
	
	for (NSUInteger i=0; i<NUMBER_OF_STANDARD2OF5CODE_CHARACTERS; i++)
	{
		char *testChar = char_encodings[i][CHARACTER_DIMENSION];
		
		if (!strcmp(testChar, searchChar))
		{
			return i;
		}
	}
	
	return -1;
}

- (char *)_encodingForCharacter:(NSString *)character
{
	char searchChar = [character UTF8String][0];
	
	for (NSUInteger i=0; i<NUMBER_OF_STANDARD2OF5CODE_CHARACTERS; i++)
	{
		char testChar = char_encodings[i][0][0];
		
		if (testChar == searchChar)
		{
			return char_encodings[i][1];
		}
	}
	
	return NULL;
}

- (BCKBarString *)_barsForEncoding:(char *)encoding
{
	BCKMutableBarString *tmpString = [BCKMutableBarString string];
	
	for (NSUInteger index=0; index<strlen(encoding); index++)
	{
		BCKBarType type = encoding[index];
		
		NSAssert(type == BCKBarTypeFull || type == BCKBarTypeSpace, @"Illegal character in encoding");
		
		[tmpString appendBar:type];
	}
	
	return [tmpString copy];
}

- (BCKBarString *)barString
{
	char *encoding = [self _encodingForCharacter:_character];
	
	if (!encoding)
	{
		return nil;
	}
	
	return [self _barsForEncoding:encoding];
}

@end
