//
//  UIColor+Hex.h
//  Carrot Prototype
//
//  Created by Steve Gifford on 7/13/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Hex)

/// Construct a UIColor from a hex value
+ (UIColor *)fromHexRGB:(uint)hex;

/// Construct a UIColor from a hex value with a specific alpha value (0-255)
+ (UIColor *)fromHexRGB:(uint)rgbValue
              withAlpha:(uint)aValue;

/// Construct a UIColor from a hex value
+ (UIColor *)fromHexARGB:(uint)rgbValue;

/// Construct a UIColor from a hex value
+ (UIColor *)fromHexRGBA:(uint)rgbValue;

@end

NS_ASSUME_NONNULL_END
