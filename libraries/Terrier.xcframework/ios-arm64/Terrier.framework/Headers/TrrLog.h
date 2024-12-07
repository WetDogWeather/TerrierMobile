//
//  TrrLog.h
//  Frontend
//
//  Created by Tim Sylvester on 7/20/22.
//

typedef enum TrrLogLevel_t {
    TrrLogVerbose = 0,
    TrrLogDebug,
    TrrLogInfo,
    TrrLogWarn,
    TrrLogError
} TrrLogLevel;

// Set, e.g., TRR_MIN_LOG_LEVEL=N to override
#if !defined(TRR_MIN_LOG_LEVEL)
# if DEBUG
#  define TRR_MIN_LOG_LEVEL TrrLogVerbose
# else
#  define TRR_MIN_LOG_LEVEL TrrLogInfo
# endif
#endif

#ifdef __cplusplus
# define TRR_EXTERN_C extern "C"
#else
# define TRR_EXTERN_C extern
#endif

// Skip logging calls below the configured level.
// The extra do/while makes it safe to use within if/else conditionals.
// Note that `level` is evaluated twice, watch out for side-effects.
#define trrLog(level, formatStr...) do {if ((level) >= (TRR_MIN_LOG_LEVEL)) { trrLog_((level), formatStr); }} while(0)
TRR_EXTERN_C void trrLog_(TrrLogLevel, const char *formatStr, ...);
TRR_EXTERN_C void trrLogv_(TrrLogLevel, const char *formatStr, va_list);
