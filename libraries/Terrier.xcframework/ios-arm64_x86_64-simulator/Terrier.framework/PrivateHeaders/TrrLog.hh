//
//  TrrLog.hh
//  Frontend
//
//  Created by Tim Sylvester on 7/20/22.
//

#import <cstdarg>

namespace Trr {

typedef struct TrrLogLevel_t
{
    typedef enum Type_t
    {
        Verbose = 0,
        Debug,
        Info,
        Warn,
        Error
    } Type;
} TrrLogLevel;

// Set, e.g., TRR_MIN_LOG_LEVEL=1 to override
#if !defined(TRR_MIN_LOG_LEVEL)
# if DEBUG
#  define TRR_MIN_LOG_LEVEL TrrLogLevel::Verbose
# else
#  define TRR_MIN_LOG_LEVEL TrrLogLevel::Info
# endif
#endif

// Skip logging calls below the configured level.
// The extra do/while makes it safe to use within if/else conditionals.
// Note that `level` is evaluated twice, watch out for side-effects.
#define trrLog(level, formatStr...) do {if ((level) >= (TRR_MIN_LOG_LEVEL)) { trrLog_((level), formatStr); }} while(0)
extern void trrLog_(TrrLogLevel::Type, const char *formatStr, ...);
extern void trrLogv_(TrrLogLevel::Type, const char *formatStr, va_list args);

}   // namespace Trr
