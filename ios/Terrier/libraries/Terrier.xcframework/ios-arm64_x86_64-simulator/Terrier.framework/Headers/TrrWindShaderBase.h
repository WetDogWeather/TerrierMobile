//
//  TrrWindShaderBase.h
//  Frontend
//
//  Created by Tim Sylvester on 7/28/22.
//

#import <WhirlyGlobe/WhirlyGlobe.h>
#import <Terrier/TrrShader.h>

@class TrrColorMap;

/**
 Base for wind particle system shaders
 */
@interface TrrWindShaderBase: MaplyShader

/**
    Maximum points in a trail
 */
@property (class, readonly) int maxTrailSize;

/**
    The current time being displayed (unix epoch)
 */
@property (nonatomic) double displayTime;

/**
    Whether we're animating timeslices
 */
@property (nonatomic) bool animatingTime;

@end
