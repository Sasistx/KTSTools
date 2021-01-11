//
//  KTSPageFaultManager.m
//  FDClangPageFault
//
//  Created by GTX on 2020/12/21.
//

#import "KTSPageFaultManager.h"
#import <dlfcn.h>
#import <libkern/OSAtomic.h>
#import "KTSDefines.h"

@implementation KTSPageFaultManager

static BOOL canTerminal = YES;

static OSQueueHead symboList = OS_ATOMIC_QUEUE_INIT;

+ (void)writeOrderToFile {
    
    NSMutableArray<NSString *> * symbolNames = [NSMutableArray array];
    while (true) {
        //offsetof 就是针对某个结构体找到某个属性相对这个结构体的偏移量
        KTSSymbolNode *node = OSAtomicDequeue(&symboList, offsetof(KTSSymbolNode, next));
        if (node == NULL) break;
        Dl_info info;
        dladdr(node->pc, &info);
        
        NSString * name = @(info.dli_sname);
        
        //添加 _
        BOOL isObjc = [name hasPrefix:@"+["] || [name hasPrefix:@"-["];
        NSString * symbolName = isObjc ? name : [@"_" stringByAppendingString:name];
        
        //去重
        if (![symbolNames containsObject:symbolName]) {
            [symbolNames addObject:symbolName];
        }
    }
    //取反
    NSArray * symbolAry = [[symbolNames reverseObjectEnumerator] allObjects];
    NSLog(@"%@",symbolAry);
    
    //将结果写入到文件
    NSString * funcString = [symbolAry componentsJoinedByString:@"\n"];
    NSString * filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"lb.order"];
    NSData * fileContents = [funcString dataUsingEncoding:NSUTF8StringEncoding];
    BOOL result = [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileContents attributes:nil];
    if (result) {
        NSLog(@"%@",filePath);
    }else{
        NSLog(@"文件写入出错");
    }
}

+ (void)stopTerminal {
    
    canTerminal = NO;
}

void abc () {
    
}

void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
    
    if (!canTerminal) {
        return;
    }
    void *PC = __builtin_return_address(0);
    KTSSymbolNode *node = malloc(sizeof(KTSSymbolNode));
    *node = (KTSSymbolNode){PC,NULL};
    //入队
    // offsetof 用在这里是为了入队添加下一个节点找到 前一个节点next指针的位置
    OSAtomicEnqueue(&symboList, node, offsetof(KTSSymbolNode, next));
}

void __sanitizer_cov_trace_pc_guard_init(uint32_t *start, uint32_t *stop) {
    
    if (!canTerminal) {
        return;
    }
    static uint64_t N;  // Counter for the guards.
    if (start == stop || *start) return;  // Initialize only once.
    printf("INIT: %p %p\n", start, stop);
    for (uint32_t *x = start; x < stop; x++)
        *x = ++N;  // Guards should start from 1.
}

@end
