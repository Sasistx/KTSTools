//
//  KTSExportManager.m
//  FDClangPageFault
//
//  Created by GTX on 2020/12/17.
//

#import "KTSExportManager.h"
#import <dlfcn.h>
#import <mach-o/getsect.h>
#import <objc/runtime.h>

#ifdef __LP64__
typedef uint64_t KTSExportValue;
typedef struct section_64 KTSExportSection;
#define KTSGetSectionByNameFromHeader getsectbynamefromheader_64
#else
typedef uint32_t KTSExportValue;
typedef struct section KTSExportSection;
#define KTSGetSectionByNameFromHeader getsectbynamefromheader
#endif

//extern struct CMD_LIST start_mysection __asm("section$start$__DATA$__mysection__");
//extern struct CMD_LIST stop_mysection  __asm("section$end$__DATA$__mysection__");

@implementation KTSExportManager

static KTSExportManager *_sharedManager;

+ (instancetype)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

#pragma mark -
#pragma mark - func

- (void)executeFuncsForKey:(NSString *)key {
    
    if (!key) {
        return;
    }
    
    NSString *fKey = [NSString stringWithFormat:@"__%@.func", key];
    
    if (!self.exportClassSetBlock) {
        KTSExecuteFunction((char *)[fKey UTF8String],
                                [self class]);
        return;
    }

    NSSet <Class>*clSet = self.exportClassSetBlock();
    [clSet enumerateObjectsUsingBlock:^(Class  _Nonnull obj, BOOL * _Nonnull stop) {
        KTSExecuteFunction((char *)[fKey UTF8String], obj);
    }];
}

void KTSExecuteFunction(char *key, Class cl) {

    Dl_info info;
    dladdr((__bridge const void *)cl, &info);
    const KTSExportValue mach_header = (KTSExportValue)info.dli_fbase;
    const KTSExportSection *mach_seciton = KTSGetSectionByNameFromHeader((KTSExportValue *)mach_header, "__KTS", key);
    if (mach_seciton == NULL) {
        return;
    }
    
    int addrOffset = sizeof(struct KTS_Func_Item);
    for (KTSExportValue addr = mach_seciton->offset; addr < mach_seciton->offset + mach_seciton->size; addr += addrOffset) {
        struct KTS_Func_Item item = *(struct KTS_Func_Item *)(mach_header + addr);
        item.funs();
    }
}

#pragma mark -
#pragma mark - block

- (void)executeBlocksForKey:(NSString *)key {
    
    if (!key) {
        return;
    }
    
    NSString *fKey = [NSString stringWithFormat:@"__%@.block", key];
    
    if (!self.exportClassSetBlock) {
        KTSExecuteFunction((char *)[fKey UTF8String],
                              [self class]);
        return;
    }
    
    NSSet <Class>*clSet = self.exportClassSetBlock();
    [clSet enumerateObjectsUsingBlock:^(Class  _Nonnull obj, BOOL * _Nonnull stop) {
        KTSExecuteFunction((char *)[fKey UTF8String], obj);
    }];
}

void KTSExecuteBlock(char *key, Class cl) {
    
    Dl_info info;
    dladdr((__bridge const void *)cl, &info);
    const KTSExportValue mach_header = (KTSExportValue)info.dli_fbase;
    const KTSExportSection *mach_seciton = KTSGetSectionByNameFromHeader((KTSExportValue *)mach_header, "__KTS", key);
    if (mach_seciton == NULL) {
        return;
    }
    
    int addrOffset = sizeof(struct KTS_Block_Item);
    for (KTSExportValue addr = mach_seciton->offset; addr < mach_seciton->offset + mach_seciton->size; addr += addrOffset) {
        struct KTS_Block_Item item = *(struct KTS_Block_Item *)(mach_header + addr);
        item.block();
    }
}

@end
