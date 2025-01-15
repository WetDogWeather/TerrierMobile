//
//  TrrColorMap_private.h
//  Frontend
//
//  Created by Tim Sylvester on 7/19/22.
//

#import <WhirlyGlobe/WhirlyGlobe.h>
#import "TrrColorMap.h"

/**
    Represents a dynamic mapping from values to colors
 */
@interface TrrColorMap ()

- (TrrShaderColorMap)toShaderWithScale:(float)scale;

@end
