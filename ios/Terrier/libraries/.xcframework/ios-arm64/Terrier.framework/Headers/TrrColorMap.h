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

/**
 Initialize the color map with an array of values and corresponding colors.
 The arrays must be of the same length and non-zero.
 Each value in the values array is a number in the default units.  Units are controller
 dependent and are Kelvin for Temperature, for instance.
 The colors are UIColor objects and will map directly to the values with interpolation
 between.  These arrays are passed all the way into the shader, rather than being
 sampled beforehand.  Thus you can do some interesting things with duplicated values at
 the freezing point, for instance.
 
 This is the only place you should be interfacing with TrrColorMap.  Ignore the rest.
 */
- (instancetype __nullable)initWithValues:(NSArray<NSNumber *> * __nonnull)values
                                 colors:(NSArray<UIColor *> * __nonnull)colors;

// Don't use this
- (instancetype __nullable)initWithBase:(float)base
                                 values:(NSArray<NSNumber *> * __nonnull)values
                                 colors:(NSArray<UIColor *> * __nonnull)colors;

// Don't use this
- (instancetype __nullable)initWithBase:(float)base
                                  scale:(float)scale
                               rgbScale:(float)rgbScale
                                  alpha:(float)alpha
                                 values:(NSArray<NSNumber *> * __nonnull)values
                                 colors:(NSArray<UIColor *> * __nonnull)colors;

// Don't use this
- (instancetype __nullable)initWithColorMap:(TrrColorMap * __nullable)other;

// Don't use this
- (instancetype __nullable)initWithColorMap:(TrrColorMap * __nullable)other
                                   scaledBy:(float)scale
                                   offsetBy:(float)offset;

// Don't use this
- (instancetype __nullable)scaledBy:(float)scale;

// Don't use this
- (instancetype __nullable)scaledBy:(float)scale
                           offsetBy:(float)offset;

// Don't use this
@property (nonatomic) float base;

// Don't use this
@property (nonatomic) float scale;

// Don't use this
@property (nonatomic) float offset;

// Don't use this
@property (nonatomic) float rgbScale;

// Don't use this
@property (nonatomic) float alpha;

// The values array
@property (nonatomic, nonnull) NSArray<NSNumber *> * values;

// The colors array
@property (nonatomic, nonnull) NSArray<UIColor *> * colors;

@end
