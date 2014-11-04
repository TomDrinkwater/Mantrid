//
//  MidiOutClass.swift
//  swiftmidi
//
//  Created by Office on 21/10/2014.
//  Copyright (c) 2014 puce. All rights reserved.
//

import Foundation
import CoreMIDI

class MidiOutClass {
    private var midiClient = MIDIClientRef()
    private var midiSource = MIDIEndpointRef()
    private var packet = UnsafeMutablePointer<MIDIPacket>.alloc(1)//allocates 256bytes + timestamp for the packet
    private var packetList = UnsafeMutablePointer<MIDIPacketList>.alloc(1)//allocates argument number of packets of above size to list mem?
  
    func openOutput() {
        MIDIClientCreate("Mantrid Client", nil, nil, &midiClient)
        var result = MIDISourceCreate(midiClient, "Mantrid",&midiSource)
        if (result == 0) {//if successful //why 0 not nil?// why is successful == 0?
             println("midi out opened")
        }
        packet = MIDIPacketListInit(packetList);
    }
    
    func closeOutput() {
        packet.destroy();//packet.dealloc(1) //if this is left in it says pointer already deallocated why?
        packetList.destroy(); packetList.dealloc(1)

        var result = MIDIClientDispose(midiClient)//not really needed coremidi will dispose on quit
        if (result == 0) {
           println("midi out closed")
        }
    }
    
    func noteOn(channel: Int, note: Int, velocity:Int) {
        midisend([Byte(0x90+channel),  Byte(note), Byte(velocity)])//send an array of the event bytes
    }
    
    func polyAfter(channel: Int, note: Int, value:Int) {
        midisend([Byte(0xA0+channel), Byte(note), Byte(value)] )
    }
    
    func channelAfter(channel: Int, value:Int) {
        midisend([Byte(0xD0+channel), Byte(value)])// only 2 bytes in this message
    }
    
    func noteOff(channel: Int, note: Int) {
        midisend([Byte(0x90+channel), Byte(note), 0] )
    }
    
    func contController(channel: Int, type: Int,  value: Int) {
        midisend([Byte(0xb0+channel), Byte(type), Byte(value)])
    }
    
    func progChange(channel: Int, value: Int) {
        midisend([Byte(0xC0+channel), Byte(value)])
    }
    
    func bankChange(channel: Int, bank: Int, program: Int) {
        midisend([Byte(0xb0+channel), Byte(0), Byte(bank)])//MSB of bank change
        midisend([Byte(0xb0+channel), Byte(0x20), Byte(bank)])//LSB of bank change
        midisend([Byte(0xC0+channel), Byte(program)])//need to send program change too
    }

    
    private func midisend(arrayToSend:[Byte]) {
        
        packet = MIDIPacketListAdd(packetList, 256, packet, 0, ByteCount(arrayToSend.count), arrayToSend);
        
        if (packet != nil ) {
            MIDIReceived(midiSource, packetList)
            //println("sent some stuff")
        } else {
            println("failed to send the midi. maybe the list is full?")
        }
        packet = MIDIPacketListInit(packetList);
        //reinitialise list for next event, done here and in openOutput to save time before sending an event- not sure if that matters
    }//end midisend
    
}//end MidiOutClass

