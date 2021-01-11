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

#import "KTSDefines.h"
#import "KTSExportManager.h"
#import "KTSPageFaultManager.h"

FOUNDATION_EXPORT double KTSToolsVersionNumber;
FOUNDATION_EXPORT const unsigned char KTSToolsVersionString[];

