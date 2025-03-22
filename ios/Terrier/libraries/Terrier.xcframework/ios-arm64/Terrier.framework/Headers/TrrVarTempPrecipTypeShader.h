//
//  TrrVarTempPrecipTypeShader.h
//  Terrier
//
//  Created by Steve Gifford on 3/21/25.
//

#import <WhirlyGlobe/WhirlyGlobe.h>
#import <Terrier/TrrShader.h>

/**
  Shader that controls temperature to precip type conversion.
 */
@interface TrrVarTempPrecipTypeShader: MaplyShader

/**
 Initialize with a unique name.
 */
- (instancetype __nullable)initWithName:(NSString * __nonnull)name
                                  viewC:(NSObject<MaplyRenderControllerProtocol> * __nonnull)viewC;

// Set the data interpolation range (data comes in scaled)
- (void)setDataRangeMin:(double)minData max:(double)maxData;

// Set an entry for temperature to precip type conversion
- (void)setEntry:(int)entry temperature:(double)temp precipType:(int)type;

@end
