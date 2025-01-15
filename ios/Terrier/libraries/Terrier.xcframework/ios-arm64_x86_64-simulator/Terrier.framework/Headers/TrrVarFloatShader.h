//
//  TrrVarFloatShader.h
//  Frontend
//
//  Created by Tim Sylvester on 7/18/22.
//

#import <WhirlyGlobe/WhirlyGlobe.h>
#import <Terrier/TrrFloatUniShader.h>

/**
 Variable rendering shader that takes normalized inputs, scales and writes them out.
 */
@interface TrrVarFloatShader: TrrFloatUniShader

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

@end
