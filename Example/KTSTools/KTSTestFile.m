//
//  KTSTestFile.m
//  KTSTools_Example
//
//  Created by GTX on 2021/1/11.
//  Copyright © 2021 p_txianggao. All rights reserved.
//

#import "KTSTestFile.h"
#import <KTSTools/KTSExportManager.h>

@implementation KTSTestFile

KTS_FUNC_EXPORT(abcde)() {
    
    [KTSTestFile test];
}

KTS_FUNC_EXPORT(abcd)() {
    
    [KTSTestFile test];
    
}

KTS_FUNC_EXPORT(abc)() {
    
    [KTSTestFile test];
}

+ (void)test {
    
    NSLog(@"test");
}

@end
