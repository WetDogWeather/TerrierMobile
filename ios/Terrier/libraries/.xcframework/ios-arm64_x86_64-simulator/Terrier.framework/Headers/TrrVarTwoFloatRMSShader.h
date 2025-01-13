//
//  TrrVarTwoFloatRMSShader.h
//  Frontend
//
//  Created by Tim Sylvester on 8/18/22.
//

#import <WhirlyGlobe/WhirlyGlobe.h>
#import <Terrier/TrrFloatUniShader.h>

/**
 Renders a two-component offscreen target as RMS values
 */
@interface TrrVarTwoFloatRMSShader: TrrFloatUniShader

/**
 Initialize with a unique name.
 */
- (instancetype __nullable)initWithName:(NSString * __nonnull)name
                                  viewC:(NSObject<MaplyRenderControllerProtocol> * __nonnull)viewC;

/**
 Change the interpolation mode for sampling.
 */
@property (nonatomic) TrrInterpMode interpolationMode;

/**
 Use our own interpolation
 */
@property (nonatomic) bool customInterpolation;

/**
    Draw no-data values to the target
 */
@property (nonatomic) bool renderNoData;

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
    Alpha value to apply
 */
@property (nonatomic) float opacity;

/**
    Set the colors to use
 */
@property (nonatomic, nullable) TrrColorMap *colorMap;

@end
