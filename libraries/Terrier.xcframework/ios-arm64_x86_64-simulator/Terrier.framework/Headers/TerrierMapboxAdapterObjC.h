//
//  TerrierMapboxAdapterObjC.h
//  MapboxTest
//
//  Created by Steve Gifford on 12/4/24.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <WhirlyGlobe/WhirlyGlobe.h>

NS_ASSUME_NONNULL_BEGIN

@interface TerrierMapboxAdapterObjC : NSObject

- (void) renderControl:(MaplyRenderControllerOverlay *)renderControl cmdBuffer:(NSObject<MTLCommandBuffer> *)cmdBuffer renderPass:(MTLRenderPassDescriptor *)renderPassDesc size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
