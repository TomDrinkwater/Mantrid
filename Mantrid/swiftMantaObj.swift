//
//  swiftMantaObj.swift
//  Mantrid
//
//  Created by Office on 23/10/2014.
//  Copyright (c) 2014 puce. All rights reserved.
//

import Foundation
//import "MantaObject.h" //not needed?

class swiftMantaObj : OcManta {
    
    //MANTA STATE DATA FROM PLAYING MANTA //should go in Manta object ie Model of MVC design pattern - are not transient and not saved
    var padValues = Array(count: 48, repeatedValue: 0) //48 items - uses let to make array of fixed length, still able to change item values
    var padChannels = Array(count: 48, repeatedValue: -1) //48 //stores channel numbers indexed by pad
    var channelPads = Array(count: 16, repeatedValue: -1) //16 //stores pad number indexed by channel
    
    //INTERNAL VARIABLES for passing and holding data at runtime, not saved, not set by user
    private var currentNote = 1
    private var currentProgram = 1//display these in gui?
    private var currentBank = 1
    //private var newChannel = 0 // I put this as a function return
    private var lastChannel = -1
    private var sliderValue = 1//need 2 of these
    private var maxPressure = 0
    var lastPad = 0
    
    var highestNote = 0
    var lowestNote = 127
    
    var userData = UserData();//INSTANCE of UserData
    var midiOut = MidiOutClass();//INSTANCE of MidiOutClass
    
    var connected = false
    var quitting = false
    
    enum LEDControlType {case PPadAndButton, SSlider, BButton}
    
    var shiftButton = false
    var programButton = false
    
    override init() {
        super.init()
        //connected = false
    }//end init
    
    func onConnect() {
        connected = self.IsConnected()
        
        if connected {
            quitting = false
            var myserial = self.GetSerialNumber()
            println("serial is \(myserial)")
            println("connected to number \(myserial)")
            println("connected = \(connected) quitting = \(quitting)")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),{self.getManta()})//start handleEvents on a new high priority thread
            SetLEDControl(PPadAndButton, withValue:true)
            self.reCalcAll()
            midiOut.openOutput()
        }
    }
    
    func onQuit() -> Bool{ //this is called from quit menu item
        quitting = true //sending message to getManta to stop
        
        //midiOut.closeOutput()
        SetLEDControl(PPadAndButton, withValue:true)
        self.ClearPadAndButtonLEDs()///this needs the subsequent handleEvents to work!
        self.SafeHandleEvents()//has to be called from this thread?
        //SetLEDControl(PPadAndButton, withValue:false)
        self.Disconnect()
        return true
    }
    /////////////////////
    func getManta()
    {
        while connected
        {
            if !quitting {
                connected = self.SafeHandleEvents()
                //println("SPLARGE connected = \(connected) quitting = \(quitting)")
            }
            NSThread.sleepForTimeInterval(0.001)//is there GCD way to do this?
            //connected = self.IsConnected()
        }
        self.Disconnect()
        println("stopping getManta and disconnecting")
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        appDelegate.menuConnectItem.title = "..reconnect"
        
    }//end mantaThread
    //////////////////////////////////////////
    
    private func getNextChannel()-> Int{
        var newChannel = 0
        var channelCheck = (lastChannel+1) % (userData.numMultiChannels+1)
        var count = 0
        while (channelPads[channelCheck] != -1) && (count <= userData.numMultiChannels){
            channelCheck = (channelCheck+1) % (userData.numMultiChannels+1)
            ++count
        }
        if count <= userData.numMultiChannels{
            newChannel = channelCheck
        } else {//steal note
            newChannel = channelCheck // steal it anyway
            // now send note off for stolen note
            var pad = channelPads[newChannel]
            var notenum = userData.padNotes[pad]
            //midiOut.noteOff(userData.baseChannel, note:notenum)
            noteOff(notenum, withValue:0, withValue:pad)
            println("stole a note")
            padChannels[pad] = -1
            channelPads[newChannel] = -1 //not needed, about to start new note on this channel anyway?
        }
        lastChannel = newChannel
        return newChannel
    } //end getchannel
    
    private func noteOn(note: Int, withValue val:Int, withValue pad:Int) {
        if userData.pressureState == UserData.PressState.PressMulti
        {
            var newChannel = getNextChannel()
            midiOut.noteOn(newChannel, note:note, velocity:val)
            padChannels[pad] = newChannel //println ("newChannel is \(newChannel)")
            channelPads[newChannel] = pad
        } else
        { // not multi mode
            midiOut.noteOn(userData.baseChannel, note:note, velocity:val)
        }
    }//end noteon
    
    private func noteOff(note: Int, withValue val:Int, withValue pad:Int) {//val is not needed should delete
        if userData.pressureState != UserData.PressState.PressMulti
        {//if not multi
            midiOut.noteOff(userData.baseChannel, note:note)//send the noteoff
        } else if padChannels[pad] != -1
        { // if multi mode and the pad has a channel assigned
            let channel = padChannels[pad]// get the channel
            midiOut.noteOff(channel, note:note)//send the noteoff
            padChannels[pad] = -1
            channelPads[channel] = -1//release the channel
        }//end off
    }
    
    override func PadEvent(row: Int32, withValue column: Int32, withValue idx: Int32, withValue value: Int32) {
        var note = userData.padNotes[Int(idx)]
        var val = Int(value*127/210)//convert manta range to midi range
        var pad = Int(idx)
        //-------THIS IS THE NOTE ON & OFF SECTION ------//
        if userData.fast == true {//send a noteon only if fast is on
            // if note turning on send note on else off
            if padValues[pad] == 0 {// was previous value 0? it must be turning on.
                noteOn(note, withValue:val, withValue:pad)
            } else if val == 0 { // is new value 0? it must be turning off.
                noteOff(note, withValue:val, withValue:pad)
            }
        }//end if fast
        //-------THIS IS THE PRESSURE SECTION ------//
        if abs(val - padValues[pad]) >= userData.thin //if change is greater than the thinning amount
        {
            switch userData.pressureState {
            case UserData.PressState.PressPoly:
                midiOut.polyAfter(userData.baseChannel, note:note, value:val)//send the poly aftertouch
            case UserData.PressState.PressMulti:
                let chan = padChannels[pad]// get the channel
                if (chan != -1) {midiOut.channelAfter(chan, value:val)}//send the channel pressure
            case UserData.PressState.PressChan:
                (val > maxPressure) ? (maxPressure = val) : (maxPressure = maxElement(padValues))
                midiOut.channelAfter(userData.baseChannel, value:maxPressure)//send the channel pressure
            case UserData.PressState.PressOff: break // do nothing and end switch
            }//end switch
        padValues[pad] = val
        }//end if thin
        
    }//end padevent
    
    override func PadVelocityEvent(row: Int32, withValue column: Int32, withValue idx: Int32, withValue velocity: Int32) {
        if userData.fast == false // only react if fast mode is off
        {
            var pad = Int(idx)
            var note = userData.padNotes[pad]
            var val = Int(velocity)
            val > 0 ? noteOn(note, withValue:val, withValue:pad) : noteOff(note, withValue:val, withValue:pad)
            //if velocity is positive send noteon else off
        }
        ////////////////////  LED SETTING BIT  ///////////////////////
        if userData.settingLEDs && velocity > 0 {
            var pad = Int(idx)
            
            if !userData.setLEDsArbitrary {
                var note = userData.padNotes[pad]
                var pitchClass = Int((note+3)%12)
                var currentState = userData.noteLeds[pitchClass]
                switch currentState { /// why cannot do ++ on an enum?
                case UserData.sLEDState.Off:userData.noteLeds[pitchClass] = UserData.sLEDState.Amber
                case UserData.sLEDState.Amber:userData.noteLeds[pitchClass] = UserData.sLEDState.Red
                case UserData.sLEDState.Red:userData.noteLeds[pitchClass] = UserData.sLEDState.Off
                }
                setLedsFromNotes()
                
            } else {//must be arbitrary layout
                var currentState = userData.arbLEDs[pad]
                switch currentState { /// why cannot do ++ on an enum?
                case UserData.sLEDState.Off:userData.arbLEDs[pad] = UserData.sLEDState.Amber
                case UserData.sLEDState.Amber:userData.arbLEDs[pad] = UserData.sLEDState.Red
                case UserData.sLEDState.Red:userData.arbLEDs[pad] = UserData.sLEDState.Off
                }
                setLedsFromArb()
            }
            let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
            appDelegate.setLedLabel()
            
            ///////////  NOTE SETTING BIT  ///////////////
        } else if userData.settingNotes && velocity > 0{ /// this whole thing only ever sets arbNotes - isonotes are recalculated on fly as required
            var pad = Int(idx)
            var val = Int(velocity)
            var note = userData.padNotes[pad]//settings are made on padNotes as that is current, saved to arbnotes when switch back to iso mode
            noteOff(note, withValue:val, withValue:pad)//stop the note on old value of pad just started above
            var pitchClass = Int((note)%12)
            (pitchClass == 11) ? (note = note-11) : (note = note+1)
            if note <= 127 { userData.padNotes[pad] = note}//check in range!
            lastPad = pad
            noteOn(note, withValue:val, withValue:pad)// start the new note//will be stopped by above on release (i hope)
            let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
            appDelegate.noteSetLabeler()
            
            reCalcAll()
        }// end settings section
    }// end padvelocity event
    
    override func SliderEvent(idx: Int32, withValue value: Int32) {
        //do something
        if (value < 4096){
            var cc = value/32;
            midiOut.contController(userData.baseChannel, type:Int(idx+1), value:Int(cc))//send mod wheel and breath
            println("slider = \(cc)")
        }
    }//end slider event
    
    override func ButtonVelocityEvent(idx: Int32, withValue velocity: Int32) {
        if velocity > 0 // don't want the release event
        {
            switch idx {
            case 0://top left button
                shiftButton = !shiftButton // toggle shift state
                shiftButton ? self.SetButtonLED(RRed, withValue:0) : self.SetButtonLED(OOff, withValue:0)
            case 1: //top right
                programButton = !programButton
                programButton ? self.SetButtonLED(RRed, withValue:1) : self.SetButtonLED(OOff, withValue:1)
            case 2: // bottom left
                if userData.settingNotes {// this preempts all normal button effects
                    var note = userData.padNotes[lastPad]
                    (note > 12) ? (note = note - 12) : (note = note + 108)// transpose lastpad down 8ve or up 8ves
                    userData.padNotes[lastPad] = note
                    let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
                    appDelegate.noteSetLabeler()
                } else if programButton {//is it in program mode?
                    if shiftButton {//send program change or bank change depending on status of shiftbutton
                        if currentBank > 0 {--currentBank}
                        midiOut.bankChange(userData.baseChannel, bank:currentBank, program:currentProgram)//send bank and prog chnage
                    } else {
                        if currentProgram > 0 {--currentProgram}
                        midiOut.progChange(userData.baseChannel, value:currentProgram)//send just prog change
                    }
                } else {
                    shiftButton ? self.Transpose(-1) : self.Transpose(-12)
                    let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
                    appDelegate.setTransposeLabeler()
                }
            case 3: // bottom right
                if userData.settingNotes {// this preempts all normal button effects
                    var note = userData.padNotes[lastPad]
                    (note < 115) ? (note = note + 12) : (note = note - 108)// transpose lastpad down 8ve or up 8ves
                    userData.padNotes[lastPad] = note
                    let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
                    appDelegate.noteSetLabeler()
                } else if programButton {
                    if shiftButton {//send program change or bank change depending on status of shiftbutton
                        if currentBank<127 {++currentBank}
                        midiOut.bankChange(userData.baseChannel, bank:currentBank, program:currentProgram)//send bank and prog chnage
                    } else {
                        if currentProgram<127 {++currentProgram}
                        ++currentProgram
                        midiOut.progChange(userData.baseChannel, value:currentProgram)//send just prog change
                    }
                } else {
                    shiftButton ? self.Transpose(1) : self.Transpose(12)//ternary operator
                    let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
                    appDelegate.setTransposeLabeler()
                }
            default:
                println("this should never happen")//do nothing
            }//end switch
        } //end if velocity > 0
    }//end ButtonVelocityEvent

    func Transpose(transposition: Int){
        if (highestNote + transposition) < 127 && (lowestNote + transposition > 0)
        {userData.transpose += transposition}
        
       // //AppDelegate.setTransposeLabeler()
        reCalcAll()
    }//end Transpose

    
    func reCalcAll() {
        userData.arbNotesLayout ? userData.setArbNotes(): userData.setIsoNotes()
        
        //if !userData.arbNotesLayout { userData.setIsoNotes() }// only recalc isonotes if using them.
        self.findExtremeNotes()
        userData.setLEDsArbitrary ? self.setLedsFromArb() : self.setLedsFromNotes()
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        appDelegate.setTransposeLabeler()
        appDelegate.noteSetLabeler()
        appDelegate.setLedLabel()
    }
    
    func findExtremeNotes(){
        lowestNote = minElement(userData.padNotes)
        highestNote = maxElement(userData.padNotes)
        println("highestNote = \(highestNote) lowestNote = \(lowestNote)")
    }
    
    func setPADled(colour: UserData.sLEDState, withValue pad:Int){// fuck all this wrapping shit
        var ocCol : LEDState = OOff
        switch colour {
        case UserData.sLEDState.Off:ocCol = OOff
        case UserData.sLEDState.Red:ocCol = RRed
        case UserData.sLEDState.Amber:ocCol = AAmber
        }
        super.SetPadLED(ocCol, withValue: Int32(pad))
    }

    func setLedsFromNotes(){
        self.ClearPadAndButtonLEDs()
        SetLEDControl(PPadAndButton, withValue:true)
        if userData.ledModeState != UserData.LEDModeState.LedOff{
            for i in 0...47 {
                var midiNote = userData.padNotes[i]
                var pitchClass = Int((midiNote+3)%12)
                var colour = userData.noteLeds[pitchClass] // colour is var of typesLEDState, rawvalue is string
                self.setPADled(colour, withValue:i)// colour then padnumber
                //println ("setting pad \(i) to \(colour.rawValue)")
            }
        }
        if userData.ledModeState != UserData.LEDModeState.LedBoth {
            SetLEDControl(PPadAndButton, withValue:false)
            println ("return ledcontrol to manta")
        }
    }//end setLedsFromNotes
    
    func setLedsFromArb(){
        self.ClearPadAndButtonLEDs()
        SetLEDControl(PPadAndButton, withValue:true)
        if userData.ledModeState != UserData.LEDModeState.LedOff{
            for i in 0...47 {
                self.setPADled(userData.arbLEDs[i], withValue:i)// colour then padnumber
                //println ("setting led for pad \(i)")
            }
        }
        if userData.ledModeState != UserData.LEDModeState.LedBoth {
            SetLEDControl(PPadAndButton, withValue:false)
            println ("return ledcontrol to manta")
        }
    }
    
}//end swiftMantaObj