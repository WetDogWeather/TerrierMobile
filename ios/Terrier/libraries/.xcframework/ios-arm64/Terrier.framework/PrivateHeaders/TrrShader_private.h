//
//  TrrShader_private.h
//  Terrier
//
//  Created by Tim Sylvester on 9/26/22.
//

#ifndef TrrShader_private_h
#define TrrShader_private_h

// todo: make this a public header?
//#import "../../../../WhirlyGlobe/common/WhirlyGlobeLib/include/WhirlyTypes.h"
//#import "../../../../WhirlyGlobe/common/WhirlyGlobeLib/include/Platform.h"

namespace WhirlyKit {
using TimeInterval = double;
extern TimeInterval TimeGetCurrent();
}

id<MTLFunction> __nullable loadShaderFunction(NSObject<MaplyRenderControllerProtocol> *__nonnull controller,
                                              NSString *__nonnull name);

#endif /* TrrShader_private_h */
