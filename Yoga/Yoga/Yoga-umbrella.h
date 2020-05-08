#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "lib/yoga/YGEnums.h"
#import "lib/yoga/YGMacros.h"
#import "lib/yoga/YGValue.h"
#import "lib/yoga/Yoga.h"

FOUNDATION_EXPORT double yogaVersionNumber;
FOUNDATION_EXPORT const unsigned char yogaVersionString[];
