//  Copyright (c) 2014 Tom Drinkwater.
//  www.tomdrinkwater.com

#ifndef _MantaObject_h
#define _MantaObject_h

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

typedef enum {OOff, AAmber, RRed} LEDState;
typedef enum  {PPadAndButton, SSlider, BButton} LEDControlType;

@interface OcManta : NSObject

- (void)PadEvent:(int)row withValue:(int)column withValue:(int)idx withValue:(int)value;
- (void)SliderEvent:(int)idx withValue:(int)value;
- (void)PadVelocityEvent:(int)row withValue:(int)column withValue:(int)idx withValue:(int)velocity;
- (void)ButtonVelocityEvent:(int)idx withValue:(int)velocity;

- (void)Disconnect;
- (int)GetSerialNumber;
- (bool)IsConnected;
- (bool)SafeConnect;
- (void)Connect;

- (void)HandleEvents;
- (bool)SafeHandleEvents;

- (void)SetPadLED:(LEDState)state withValue:(int)ledID;
- (void)SetButtonLED:(LEDState)state withValue:(int)ledID;
- (void)SetLEDControl:(LEDControlType)control withValue:(bool)state;
- (void)ClearPadAndButtonLEDs;


@end

#endif