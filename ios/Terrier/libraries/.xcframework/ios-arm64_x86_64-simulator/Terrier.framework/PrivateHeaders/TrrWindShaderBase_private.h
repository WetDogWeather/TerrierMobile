//
//  TrrWindShaderBase_private.h
//  Frontend
//
//  Created by Tim Sylvester on 7/28/22.
//

#import <WhirlyGlobe/WhirlyGlobe.h>
#import <Terrier/TrrWindShaderBase.h>
#import <Terrier/TrrShader_private.h>

@class TrrColorMap;

/**
 Renders wind
 */
@interface TrrWindShaderBase ()

/**
 The view controller
 */
@property (readonly) NSObject<MaplyRenderControllerProtocol> * __nullable viewController;

/**
    Maximum number of trails to establish
 */
@property (nonatomic) int maxTrailCount;

/**
    Minimum points in a trail
 */
@property (nonatomic) int minTrailSize;

/**
    Wind trail width
 */
@property (nonatomic) float trailWidth;

/**
    How much we move forward for each sample
 */
@property (nonatomic) float trailAdvanceRate;

/**
    Maximum turn to allow per segment
 */
@property (nonatomic) float turnAngleLimit;

/**
    Maximum sum of under-turn before stopping trail advance
 */
@property (nonatomic) float turnErrorLimit;

/**
 Smallest magnitude to consider to have meaningful direction
 */
@property (nonatomic) float minVelocity;

/**
 Adjustment factor for automatic scale-change reset.
 */
@property (nonatomic) float scaleResetFactor;

/**
 Log base of modulation factor
 */
@property (nonatomic) float shapeParamB;

/**
 Power of modulation factor
 */
@property (nonatomic) float shapeParamP;

/**
 Limit of modulation factor
 */
@property (nonatomic) float shapeParamS;

/**
 Fade-in time
 */
@property (nonatomic) float fadeIn;

/**
 Fade-out time
 */
@property (nonatomic) float fadeOut;

/**
 Minimum lifetime
 */
@property (nonatomic) WhirlyKit::TimeInterval trailLifetimeMin;

/**
 Maximum lifetime
 */
@property (nonatomic) WhirlyKit::TimeInterval trailLifetimeMax;

/**
    Number of "particles" within the trail
 */
@property (nonatomic) float texPeriod;

/**
    Motion rate
 */
@property (nonatomic) float texRate;

/**
    Effect of velocity on tex rate
 */
@property (nonatomic) float texVelRate;

/**
    Exponent on velocity effect
 */
@property (nonatomic) float texVelExp;

/**
    Texture coordinate offsets
 */
@property (nonatomic) float texOffsetX;
@property (nonatomic) float texOffsetY;

/**
    Show every Nth copy
 */
@property (nonatomic) int texInterval;

/**
 Scale output values to the given range.
 */
@property (nonatomic) float dataRangeMin;
@property (nonatomic) float dataRangeMax;

/**
  The value indicating no data is available for the sample
 */
@property (nonatomic) float noDataValue;

/**
    Base color multiplier
 */
@property (nonatomic, nullable) UIColor *color;

/**
    Set the colors to use
 */
@property (nonatomic, nullable) TrrColorMap *colorMap;

/**
    Whether to show static arrows in place of trails while animating timeslices
 */
@property (nonatomic) bool animArrows;

/**
    The fraction of trails to show as arrows
 */
@property (nonatomic) float arrowShowFrac;

/**
    Length of arrows (pixels)
 */
@property (nonatomic) float arrowLength;

/**
    Width of arrows (pixels)
 */
@property (nonatomic) float arrowWidth;

/**
    The texture to use for trails
 */
@property (nonatomic, nullable) MaplyTexture *trailTexture;

/**
    The texture to use for arrows
 */
@property (nonatomic, nullable) MaplyTexture *arrowTexture;



/**
 Initialize with a unique name.
 */
- (instancetype __nullable)init:(NSString * __nonnull)name
                         vertex:(NSString * __nonnull)vertName
                       fragment:(NSString * __nullable)fragName
                          viewC:(NSObject<MaplyRenderControllerProtocol> * __nonnull)viewC;

/**
    Recycle the existing wind trails over the specitied interval
 */
- (void)resetTrails:(WhirlyKit::TimeInterval)overTime;

/**
    Schedule an update of the shader uniforms
 */
- (void)scheduleUpdate;

/**
    Update the shader uniforms immediately
 */
- (void)updateUniforms;


@end
