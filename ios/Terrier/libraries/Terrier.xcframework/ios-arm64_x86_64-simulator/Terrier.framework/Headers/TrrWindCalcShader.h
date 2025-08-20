//
//  TrrWindCalcShader.h
//  Frontend
//
//  Created by Tim Sylvester on 7/19/22.
//

#import <WhirlyGlobe/WhirlyGlobe.h>
#import <Terrier/TrrWindShaderBase.h>

/**
 Calculation shader for wind rendering
 */
@interface TrrWindCalcShader: TrrWindShaderBase

/**
    Wind trail width
 */
@property (nonatomic) float trailWidth;

/**
    How much we move forward for each sample
 */
@property (nonatomic) float trailAdvanceRate;

/**
    Exponent controlling how fast we advance
 */
@property (nonatomic) float trailVelExp;

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
 We scale between min and max velocity for some calculations
 */
@property (nonatomic) float maxVelocity;

/**
 Adjustment factor for automatic scale-change reset.
 */
@property (nonatomic) float scaleResetFactor;

/**
    Maximum points in a trail
 */
@property (class, readonly) int maxTrailSize;

/**
    Maximum number of trails
 */
@property (nonatomic) int maxTrailCount;

/**
    Maximum number of trail points (particles)
 */
@property (nonatomic) int maxTrailPoints;

/**
    How long trails remain before being recycled (seconds)
 */
@property (nonatomic) double trailLifetimeMin;

/**
    How long trails remain before being recycled (seconds)
 */
@property (nonatomic) double trailLifetimeMax;

/**
    Minimum points to allow when establishing a trail
 */
@property (nonatomic) int minTrailSize;

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
    Set the colors to use
 */
@property (nonatomic, nullable) TrrColorMap *colorMap;

/**
    Whether to show static arrows in place of trails while animating timeslices
 */
@property (nonatomic) bool animArrows;

@property (nonatomic) bool offlineMode;

@property (nonatomic) bool useInteraction;

@property (nonatomic) bool continuousMode;

/**
 Initialize with a unique name.
 */
- (instancetype __nullable)initWithName:(NSString * __nonnull)name
                                  viewC:(NSObject<MaplyRenderControllerProtocol> * __nonnull)viewC;

/**
    Recycle the existing wind trails over the specitied interval
 */
- (void)resetTrails:(double)overTime;

@end
