#import <Foundation/Foundation.h>
#import "Manta.h"
#import "MantaExceptions.h"
#import "Wrapper.h"

class CppManta: public Manta
{
    
public:
    CppManta(OcManta* cpmanta)
    : ocmanta(cpmanta)
    {
    }
    
    ~CppManta()
    {
    }
    
    void PadEvent(int row, int column, int idx, int value)
    {
        [ocmanta PadEvent:row withValue:column withValue:idx withValue:value];
    }
    
    void PadVelocityEvent(int row, int column, int idx, int velocity)
    {
        [ocmanta PadVelocityEvent:row withValue:column withValue:idx withValue:velocity];
    }
    
    void SliderEvent(int idx, int value)
    {
        [ocmanta SliderEvent:idx withValue:value];
    }
    
    void ButtonVelocityEvent(int idx, int velocity){
        [ocmanta ButtonVelocityEvent:idx withValue:velocity];
    }
    
private:
    OcManta* ocmanta;//create instance of OcManta referred to by ocmanta
};

/////////////////////////////////////////////////////

@implementation OcManta
{
    CppManta* cpmanta;
}

-(id) init
{
    self = [super init];
    if (self)
    {
        cpmanta = new CppManta(self);//create instance of CppManta referred to by cpmanta
    }
    return self;
}

-(void) dealloc
{
    delete cpmanta;
    //[super dealloc];
}

-(int) GetSerialNumber
{
    int serial = cpmanta->GetSerialNumber();
    return serial;
}

-(bool) IsConnected
{
    bool connected = cpmanta->IsConnected();
    return connected;
}

-(void) HandleEvents
{
    cpmanta->HandleEvents();
}

-(bool) SafeHandleEvents
{
    try
    {
        cpmanta->HandleEvents();
        return true;
    }
    catch (std::exception& err)
    {
        const char* txt = err.what();
        NSLog([NSString stringWithUTF8String: txt]);
        return false;
    }
    catch (...)
    {
        NSLog(@"Unknown error...");
        return false;
    }
}

-(bool) SafeConnect
{
    try
    {
        cpmanta->Connect();
        NSLog(@"Connected");
        return true;
    }
    catch (std::exception& err)
    {
        const char* txt = err.what();
        NSLog([NSString stringWithUTF8String: txt]);
        return false;
    }
    catch (...)
    {
        NSLog(@"Failed to connect...");
        return false;
    }
}

-(void) Connect
{
    cpmanta->Connect();
}

-(void) Disconnect
{
    cpmanta->Disconnect();
}

- (void) ClearPadAndButtonLEDs
{
    cpmanta->ClearPadAndButtonLEDs();
}

- (void)SetPadLED:(LEDState)state withValue:(int)ledID;
{
    if (state == RRed){
        cpmanta->SetPadLED(cpmanta->Red, ledID);
        //NSLog(@"set pad to red %d", ledID);
    }else if (state == AAmber){
        cpmanta->SetPadLED(cpmanta->Amber, ledID);
    }else if (state == OOff) {
        cpmanta->SetPadLED(cpmanta->Off, ledID);
    }
}

- (void)SetButtonLED:(LEDState)state withValue:(int)ledID;
{
    if (state == RRed){
        cpmanta->SetButtonLED(cpmanta->Red, ledID);
    }else if (state == AAmber){
        cpmanta->SetButtonLED(cpmanta->Amber, ledID);
    }else if (state == OOff) {
        cpmanta->SetButtonLED(cpmanta->Off, ledID);
    }
}

- (void)SetLEDControl:(LEDControlType)control withValue:(bool)state;
{
    if (control == PPadAndButton){
        cpmanta->SetLEDControl(cpmanta->PadAndButton, state);
    }else if (control == SSlider){
        cpmanta->SetLEDControl(cpmanta->Slider, state);
    }else if (control == BButton) {
        cpmanta->SetLEDControl(cpmanta->Button, state);
    }
}

- (void)PadEvent:(int)row withValue:(int)column withValue:(int)idx withValue:(int)value;
{
    //overidden in swift
}

- (void)SliderEvent:(int)idx withValue:(int)value;
{
    //overidden in swift
}

- (void)PadVelocityEvent:(int)row withValue:(int)column withValue:(int)idx withValue:(int)velocity;
{
    //overidden in swift
}

- (void)ButtonVelocityEvent:(int)idx withValue:(int)velocity;
{
    //overidden in swift
}

@end