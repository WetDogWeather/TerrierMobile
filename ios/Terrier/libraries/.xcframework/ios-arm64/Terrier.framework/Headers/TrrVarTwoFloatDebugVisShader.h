//
//  TrrVarTwoFloatDebugVisShader.h
//  Frontend
//
//  Created by Tim Sylvester on 7/15/22.
//

#import <WhirlyGlobe/WhirlyGlobe.h>
#import <Terrier/TrrFloatUniShader.h>

/**
 Allows a two-float-valued variable target to be meaningfully rendered to an RGBA target
 */
@interface TrrVarTwoFloatDebugVisShader: TrrFloatUniShader

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

@end
