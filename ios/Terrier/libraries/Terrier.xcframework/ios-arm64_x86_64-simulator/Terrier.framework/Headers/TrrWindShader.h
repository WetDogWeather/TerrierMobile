//
//  TrrWindShader.h
//  Frontend
//
//  Created by Tim Sylvester on 7/19/22.
//

#import <WhirlyGlobe/WhirlyGlobe.h>
#import <Terrier/TrrWindShaderBase.h>

/**
 Renders wind
 */
@interface TrrWindShader: TrrWindShaderBase

/**
 Initialize with a unique name.
 */
- (instancetype __nullable)initWithName:(NSString * __nonnull)name
                                  viewC:(NSObject<MaplyRenderControllerProtocol> * __nonnull)viewC;

/**
 Fade-in time
 */
@property (nonatomic) float fadeIn;

/**
 Fade-out time
 */
@property (nonatomic) float fadeOut;

/**
    Wind trail width
 */
@property (nonatomic) float trailWidth;

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
    Number of "particles" within the trail
 */
@property (nonatomic) float texPeriod;

/**
    Motion rate
 */
@property (nonatomic) float texRate;

/**
    Effect of velocity on motion
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
    Show every Nth copy of the texture
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
@property (nonatomic,nullable) UIColor *color;

/**
    Set the colors to use
 */
@property (nonatomic, nullable) TrrColorMap *colorMap;

/**
    Set the opacity blended into the colors.
 */
@property (nonatomic) float opacity;

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

/// If set we're writing to an offline texture, which tweaks things a bit
@property (nonatomic) bool offlineMode;

/**
    The texture to use for trails
 */
@property (nonatomic, nullable) MaplyTexture *trailTexture;

/**
    The texture to use for arrows
 */
@property (nonatomic, nullable) MaplyTexture *arrowTexture;

@end
