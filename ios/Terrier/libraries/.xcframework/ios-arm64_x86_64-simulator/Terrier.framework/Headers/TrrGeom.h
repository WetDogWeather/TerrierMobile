//
//  TrrGeom.h
//  Terrier
//
//  Created by Tim Sylvester on 8/3/22.
//

#if defined(__cplusplus)
namespace Trr {

// these should be pulled in from Whirly, but they're not public
template<typename T> constexpr T DegToRad(T deg) { return (T)(deg / 180.0 * M_PI); }
template<typename T> constexpr T RadToDeg(T rad) { return (T)(rad / M_PI * 180.0); }

}

#else

inline float TrrDegToRadF(float deg) { return (float)(deg / 180.0 * M_PI); }
inline float TrrRadToDegF(float rad) { return (float)(rad / M_PI * 180.0); }
inline double TrrDegToRadD(double deg) { return (deg / 180.0 * M_PI); }
inline double TrrRadToDegD(double rad) { return (rad / M_PI * 180.0); }

#endif

