//
//  PDRouterPageRegistry.m
//  PDPower
//
//  Created by liang on 2024/3/20.
//

#import "PDRouterPageRegistry.h"
#import <mach-o/getsect.h>
#import <mach-o/dyld.h>

@implementation PDRouterPageRegistry {
    NSMutableDictionary<NSString *, NSString *> *_pathToClassMap;
}

+ (PDRouterPageRegistry *)defaultRegistry {
    static PDRouterPageRegistry *__defaultRegistry;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultRegistry = [[self alloc] init];
    });
    return __defaultRegistry;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _pathToClassMap = [NSMutableDictionary dictionary];
        [self loadPages];
    }
    return self;
}

- (void)loadPages {
    for (uint32_t index = 0; index < _dyld_image_count(); index++) {
#ifdef __LP64__
        uint64_t addr = 0;
        const struct mach_header_64 *header = (const struct mach_header_64 *)_dyld_get_image_header(index);
        const struct section_64 *section = getsectbynamefromheader_64(header, "__DATA", "pd_exp_page");
#else
        uint32_t addr = 0;
        const struct mach_header *header = (const struct mach_header *)_dyld_get_image_header(index);
        const struct section *section = getsectbynamefromheader(header, "__DATA", "pd_exp_page");
#endif
        
        if (section == NULL) { continue; }
        
        if (header->filetype != MH_OBJECT && header->filetype != MH_EXECUTE && header->filetype != MH_DYLIB) {
            continue;
        }
        
        for (addr = section->offset; addr < section->offset + section->size; addr += sizeof(PDPageRouteInfo)) {
#ifdef __LP64__
            PDPageRouteInfo *page = (PDPageRouteInfo *)((uint64_t)header + addr);
#else
            PDPageRouteInfo *page = (PDPageRouteInfo *)((uint32_t)header + addr);
#endif
            if (!page) { continue; }
            
            NSString *pagepath = [NSString stringWithUTF8String:page->pagePath];
            NSString *classname = [NSString stringWithUTF8String:page->className];
            _pathToClassMap[pagepath] = classname;
        }
    }
}

- (Class)classForPath:(NSString *)path {
    return NSClassFromString(_pathToClassMap[path]);
}

@end
