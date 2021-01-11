//
//  KTSDefines.h
//  Pods
//
//  Created by GTX on 2020/12/17.
//

#ifndef KTSDefines_h
#define KTSDefines_h

#pragma mark -
#pragma mark - 统一func触发相关

typedef void (*fun)(void);
struct KTS_Func_Item {
    char * _Nullable key;
    fun _Nullable funs;
};

#define KTS_FUNC_SECTION(key) __attribute__((used,__section__("__KTS," "__"#key ".func")))

#define _KTS_FUNC_EXPORT1(key, line) \
static void _kts_##key##line(void); \
KTS_FUNC_SECTION(key) \
const struct KTS_Func_Item kts_cmd_fn_##key##line = (struct KTS_Func_Item){(char *)(&#key), &(_kts_##key##line)}; \
static void _kts_##key##line \

#define _KTS_FUNC_EXPORT0(key, line) _KTS_FUNC_EXPORT1(key, line)
#define KTS_FUNC_EXPORT(key) _KTS_FUNC_EXPORT0(key, __LINE__)

#pragma mark -
#pragma mark - 统一block触发相关

typedef void(^kts_block)(void);
struct KTS_Block_Item {
    char * _Nullable key;
    __unsafe_unretained kts_block _Nullable block;
};

#define KTS_BOLCK_SECTION(key) __attribute__((used,__section__("__KTS," "__"#key ".block")))
#define _KTS_BLOCK_EXPORT1(key, block, line) \
KTS_FUNC_SECTION(key) \
static const struct KTS_BLOCK_Item kts_cmd_block_##key##line = (struct KTS_BLOCK_Item){(char *)(&#key), block}; \
static void _kts_##key##line \

#define _KTS_BLOCK_EXPORT0(key, block, line) _KTS_BLOCK_EXPORT1(key, block, line)
#define KTS_BLOCK_EXPORT(key, block) _KTS_BLOCK_EXPORT0(key, block, __LINE__)

#pragma mark -
#pragma mark - Page记录相关

typedef struct{
    void * _Nullable pc;
    void * _Nullable next;
} KTSSymbolNode;

#endif /* KTSDefines_h */
