//
//  TrrColorMap.h
//  Frontend
//
//  Created by Tim Sylvester on 7/19/22.
//

#import <WhirlyGlobe/WhirlyGlobe.h>
#import <Terrier/TrrShader.h>

/**
    Represents a dynamic mapping from values to colors
 */
@interface TrrColorMap : NSObject

/** Initialize an empty colormap.  This is not what you want. */
- (instancetype __nonnull)init;

- (instancetype __nullable)initWithValues:(NSArray<NSNumber *> * __nonnull)values
                                 colors:(NSArray<UIColor *> * __nonnull)colors;

- (instancetype __nullable)initWithBase:(float)base
                                 values:(NSArray<NSNumber *> * __nonnull)values
                                 colors:(NSArray<UIColor *> * __nonnull)colors;

- (instancetype __nullable)initWithBase:(float)base
                                  scale:(float)scale
                               rgbScale:(float)rgbScale
                                  alpha:(float)alpha
                                 values:(NSArray<NSNumber *> * __nonnull)values
                                 colors:(NSArray<UIColor *> * __nonnull)colors;

- (instancetype __nullable)initWithColorMap:(TrrColorMap * __nullable)other;
- (instancetype __nullable)initWithColorMap:(TrrColorMap * __nullable)other
                                   scaledBy:(float)scale
                                   offsetBy:(float)offset;

- (instancetype __nullable)scaledBy:(float)scale;

- (instancetype __nullable)scaledBy:(float)scale
                           offsetBy:(float)offset;

@property (nonatomic) float base;

@property (nonatomic) float scale;

@property (nonatomic) float offset;

@property (nonatomic) float rgbScale;

@property (nonatomic) float alpha;

@property (nonatomic, nonnull) NSArray<NSNumber *> * values;

@property (nonatomic, nonnull) NSArray<UIColor *> * colors;

@end
