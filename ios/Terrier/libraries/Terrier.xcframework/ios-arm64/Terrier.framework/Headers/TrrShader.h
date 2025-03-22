//
//  TrrShader.h
//  Frontend
//
//  Created by Tim Sylvester on 7/15/22.
//

#ifndef TrrShader_h
#define TrrShader_h

#import <simd/simd.h>

#if defined(__METAL_VERSION__)
# define POSITION_ATTR [[position]]
#else
# define POSITION_ATTR

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_MACCATALYST
// No half type, but we really just need to reserve space.
//typedef uint16_t float16_t;
#endif

//typedef uint16_t float16_t;
typedef simd_float16 half;
//typedef struct simd_half3_t { simd_float16 _[3]; } __attribute__((aligned(8))) simd_half3;
#endif


// Interpolation mode for sampling
typedef enum TrrInterpMode_t {
    TrrNearest,
    TrrBilinear,
    TrrBicubic
} TrrInterpMode;

typedef enum TrrArgBufferEntries_t
{
    TrrUniformVarEntry = 401,
} TrrArgBufferEntries;

typedef struct TrrShaderColorMapEntry_t
{
    float value;
    simd_float4 color;
} TrrShaderColorMapEntry;

typedef struct TrrShaderColorMap_t
{
    uint16_t count;
    // Linear at expBase==1
    // Sub-linear for 1<expBase (f(0.5)<0.5)
    // Super-linear for 0<expBase<=1 (f(0.5)>0.5)
    float expBase;
    TrrShaderColorMapEntry entries[32];
} TrrShaderColorMap;

// Shader arguments for float-valued targets where all
// components have the same range and no-data values.
typedef struct TrrVarFloatShaderUniforms_t
{
    TrrInterpMode interpMode; // How we're interpolating
    simd_float2 dataRange;    // Min/max data values
    float noDataVal;
    float opacity;
    TrrShaderColorMap colorMap[8];
    float displayTime;          // The time currently being displayed
    bool animatingTime;         // if we're currently animating timeslices
    bool interpCustom;
    bool renderNoData;          // draw no-data to target
    bool colorMapIndexMode;
} TrrVarFloatShaderUniforms;

typedef struct TrrTempPrecipEntry_t
{
    // Up to this temperature
    float temperature;
    // Is this precip type value
    int precipValue;
} TrrTempPrecipEntry;

// Uniforms for temperature to precip type conversion
typedef struct TrrVarTempPrecipTypeUniforms_t
{
    simd_float2 dataRange;    // Min/max data values
    int numPrecipEntry;
    TrrTempPrecipEntry entries[8];
} TrrVarTempPrecipTypeUniforms;


typedef struct TrrWindUniforms_t
{
    float trailWidth;           // width of generated geometry
    float trailAdvance;         // length of geometry segments
    float turnAngleLimit;       // Maximum turn to allow per segment
    float turnErrorLimit;       // Maximum sum of under-turn before stopping trail advance
    float minVelocity;          // Smallest magnitude to consider to have meaningful direction
    float resetStartTime;       // Start of reset period
    float resetEndTime;         // End of reset period
    float scaleResetFactor;     // Adjustment factor for automatic scale-change reset.
    float shapeParamB;          // Log base of modulation factor
    float shapeParamP;          // Power of modulation factor
    float shapeParamS;          // Limit of modulation factor
    float lifetimeMin;          // Minimum trail lifetime
    float lifetimeMax;          // Maximum trail lifetime
    float fadeIn;               // Fade-in time
    float fadeOut;              // Fade-out time
    float texPeriod;            // Number of texture applications
    float texRate;              // Rate of texture movement
    float texVelRate;           // Velocity effect on tex rate
    float texVelExp;            // Exponent of velocity factor
    simd_float2 texOffset;
    uint16_t texInterval;
    float noDataVal;
    uint32_t maxTrailPoints;
    uint32_t maxTrailCount;
    uint16_t minTrailSize;
    simd_float2 dataRange;
    simd_float4 color;
    float opacity;
    TrrShaderColorMap colorMap;
    float displayTime;          // The time currently being displayed
    bool animatingTime;         // If we're currently animating timeslices
    bool animArrows;            // If we're showing arrows when animating
    float arrowShowFrac;        // The number of arrows to show as a fraction of the number of trails
    float arrowLength;
    float arrowWidth;
    bool offlineMode;           // Set if we're rendering to an offline texture
} TrrWindUniforms;

enum { MaxWindTrailSize = 30 };

typedef struct TrrWindTrailData_t
{
    simd_float3 modelPos[MaxWindTrailSize];
    float startTime;        // time at which this trail was established
    float pauseTime;        // time at which motion was paused
    float lifetime;         // current lifetime of this trail (seconds)
    float scale;             // scale at which this trail was established
    half meanSpeed;         // mean velocity of wind along this trail
    uint16_t updateFrame;   // frame count after last update
    uint8_t trailSize;      // number of valid positions
} TrrWindTrailData;

#ifdef __cplusplus
extern "C" {
#endif
float f16tof32(uint16_t);
#ifdef __cplusplus
}
#endif

#endif /* TrrShader_h */
