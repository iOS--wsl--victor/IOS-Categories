//
//  NSString+Helpers.m
//  WordPress
//
//  Created by John Bickerstaff on 9/9/09.
//  
//

#import "NSString+Helpers.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Helpers)

#pragma mark Helpers

// Taken from AFNetworking's AFPercentEscapedQueryStringPairMemberFromStringWithEncoding
- (NSString *)stringByUrlEncoding
{
    static NSString * const kAFCharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    static NSString * const kAFCharactersToLeaveUnescaped = @"[].";

	return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)self,
          (__bridge CFStringRef)kAFCharactersToLeaveUnescaped,
           (__bridge CFStringRef)kAFCharactersToBeEscaped,
            kCFStringEncodingUTF8);
}

- (NSMutableDictionary *)dictionaryFromQueryString {
    if (!self)
        return nil;

    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    NSArray *pairs = [self componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs) {
        NSRange separator = [pair rangeOfString:@"="];
        NSString *key, *value;
        if (separator.location != NSNotFound) {
            key = [pair substringToIndex:separator.location];
            value = [[pair substringFromIndex:separator.location + 1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        } else {
            key = pair;
            value = @"";
        }

        key = [key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [result setObject:value forKey:key];
    }

    return result;
}

- (NSString *)stringByReplacingHTMLEmoticonsWithEmoji {
    NSMutableString *result = [NSMutableString stringWithString:self];

    NSDictionary *replacements = @{
                                   @"arrow": @"➡",
                                   @"biggrin": @"😃",
                                   @"confused": @"😕",
                                   @"cool": @"😎",
                                   @"cry": @"😭",
                                   @"eek": @"😮",
                                   @"evil": @"😈",
                                   @"exclaim": @"❗",
                                   @"idea": @"💡",
                                   @"lol": @"😄",
                                   @"mad": @"😠",
                                   @"mrgreen": @"🐸",
                                   @"neutral": @"😐",
                                   @"question": @"❓",
                                   @"razz": @"😛",
                                   @"redface": @"😊",
                                   @"rolleyes": @"😒",
                                   @"sad": @"😞",
                                   @"smile": @"😊",
                                   @"surprised": @"😮",
                                   @"twisted": @"👿",
                                   @"wink": @"😉"
                                   };

    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<img src='.*?wp-includes/images/smilies/icon_(.+?).gif'.*?class='wp-smiley' ?/?>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:result options:0 range:NSMakeRange(0, [result length])];
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        NSRange range = [match rangeAtIndex:1];
        NSString *icon = [result substringWithRange:range];
        NSString *replacement = [replacements objectForKey:icon];
        if (replacement) {
            [result replaceCharactersInRange:[match range] withString:replacement];
        }
    }
    return [NSString stringWithString:result];
}

/*
 * Uses a RegEx to strip all HTML tags from a string and unencode entites
 */
- (NSString *)stringByStrippingHTML {
    return [self stringByReplacingOccurrencesOfString:@"<[^>]+>" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}


- (NSString *)stringByRemovingScriptsAndStrippingHTML {
    NSMutableString *mString = [self mutableCopy];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<script[^>]*>[\\w\\W]*</script>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:mString options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, [mString length])];
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        [mString replaceCharactersInRange:match.range withString:@""];
    }
    return [mString stringByStrippingHTML];
}
@end

