//
//  KTSExportManager.h
//  FDClangPageFault
//
//  Created by GTX on 2020/12/17.
//

#import <Foundation/Foundation.h>
#import "KTSDefines.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSSet <Class>*_Nullable(^KTSExportClassSet)(void);

@interface KTSExportManager : NSObject

@property (nonatomic, copy) KTSExportClassSet exportClassSetBlock;

+ (instancetype)sharedManager;

- (void)executeFuncsForKey:(NSString *)key;

- (void)executeBlocksForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
