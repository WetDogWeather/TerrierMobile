//
//  TrrFloatUniShader.h
//  Frontend
//
//  Created by Tim Sylvester on 7/19/22.
//

#import <WhirlyGlobe/WhirlyGlobe.h>
#import <Terrier/TrrShader.h>

@class TrrColorMap;

/**
 Base for shaders taking `TrrVarFloatShaderUniforms`
 */
@interface TrrFloatUniShader: MaplyShader

/**
    The current time being displayed (unix epoch)
 */
@property (nonatomic) double displayTime;

/**
    Whether we're animating timeslices
 */
@property (nonatomic) bool animatingTime;

@end
