Mantrid
=======

Snyderphonics Manta to Midi

Mantrid

Mantrid is an application to convert output from the Snyderphonics Manta into standard Midi messages.

It uses the libmanta library by Spencer Russell. 

Backstory:

Some time ago Richard Knight made a program for the same purpose, called MacManta. It was very basic and I wanted more features so I hacked it to have more features. More recently I decided to learn more programming, and one of the things I want to learn is to make OSX applications. Mantrid is written in Swift (plus the C++ libmanta and some objC to bridge them) and I used Xcode, in contrast to macManta which was written in ObjC and built with cMake.  Mantrid is intended as a conceptual extension and rewrite of MacManta. However, there is no code from MacManta in Mantrid, and much of it is done differently. Richard helped me quite a lot with some of the concepts, especially  bridging the C++ libmanta with an OSX app.

Features and controls

Like MacManta, Mantrid is a menubar app. This is more convenient to keep it out of the way while you are playing. However it does have a configuration window, which you show and hide from the menu.

The configuration menu has four sections:

Layout

Mantrid assumes that you will most likely want to use an isomorphic layout. (same fingering in all keys). The top two menus specify the intervals from any given pad to the pad to the upper left of it, and the pad to the upper right. This is sufficient to define a complete layout. The menu below the up right and up left menus selects isomorphic or arbitrary layout.

The transpose buttons should be self explanatory.

The field of text shows the midi note numbers assigned to each pad, and updates as you change things. You can change this display to show note names instead with the menu above it.

It is quite possible to select upright and upleft values such that the resulting layout does not fit on the manta within the 127 midi notenumbers. When this happens it will automatically transpose the layout to fit, if possible. If not possible it will set over range pads to note 127 and under range pads to note 0. Such layouts are unlikely to be useful!

It is also possible to use arbitrary, non isomorphic note layouts. To do this change the menu to “arbitrary layout”. Setting the arbitrary layout is a little cumbersome and an additional gui may be added (much) later if people want it.

To set the notes for an arbitray layout press the “Set Arb Notes” button. It turns red.

Then touch the pad on the manta you want to change. Each touch increases the notenumber by one, but loops around a single octave. To transpose a pad by an octave use the bottom left and bottom right buttons on the Manta, these will transpose the last touched pad up or down an octave. (this corresponds with their function of transposing the whole layout up and down when not in note setting mode).

When finished setting notes, press the red button to go back to normal playing mode with the new layout set.

You can switch between arbitrary and isomorphic modes whithout losing the settings for each.

Another way to create a arbitrary note layout is to manually edit the plist file that Mantrid uses to store settings. (see the global section for file saving info).

Expression

The pad coverage value from the Manta can be handled in one of four ways:

1. Off - don’t send continuous messages at all, just note ons and offs.
2. Polyphonic Aftertouch, send the continuous pad values as Polyphonic Aftertouch
3. Channel Pressure, send the value of the pad with the highest value, as channel pressure.
4. Multi. Assign each note a separate channel to play on, send the pad values as channel pressure on the assigned channel for each note. Uses a round robin allocation, and always steals the oldest note if note stealing required.

Thinning - this menu sets how much the pad value has to change from the previous one to send a message. /2 means that if the value goes from 64 to 65 to 66 then a message will not be sent for the middle value (65) however if the values received from the manta were 64 66 59 then a message would be sent for each.

The multi channels menu below this sets how many channels to use in multi mode. Multi mode always starts from channel 1 and goes up to the number set in the menu. The golbal channel has no effect in multi mode, and the multi mode menu has no effect in any other mode.

The button Fast Vel Mode/Manta Vel Mode changes how velocity data included in noteon message is calculated. In fast velocity mode the velocity value is simply the pad coverage value of the very first touch on the pad. This works well for me. In Manta velocity mode the velocity value is calculated by the Manta using the first two values when you touch the pad. This gives a approximation of how fast you applied your finger to the pad, but it increases latency but at least 6ms as the Manta has to wait for 2 scans of the pads to get 2 values to use for the calculation.

I would like to add mapping curves/tables for the pad values in a future version. This is something like velocity curves, but applied to the continuous pad values, and ideally graphically user editable.

LEDs

You can set the Manta’s lights in the LED section. The top menu selects between 3 modes. Off, in which you select no lights, but the Manta lights up the pad you are playing amber. Red, in which you can set the red lights but the Manta still has control of the Amber LEDs, and Both, in which you can set Red and Amber static lights, and the manta does not light up the pad you are playing.

You can define your pattern of static lights in two different ways. Set by note lights up all pads of the same pitch class the same colour, and if you change the layout the lights will follow then notes, and set by pad lets you set any pad to any colour independently of the note layout and if you change the note layout the pads will stay the colour they are even though they are playing different notes.

To set the lights press the “Set LED’s now” button. It turns red.

Touch the pad you want to change. It will cycle through off, amber, red with each touch.

If you are in “set by note” mode then all other pads of the same pitch class will change with it, if in “set by pad” then only the one pad will change. The settings for set by pad and set by note are separate and you can swap between them without losing your settings in the other.

Press the red button again to return to playing mode. It will change back to blue-grey.


Global

The channel menu selects which midi channel to send output to. It has no effect in multi mode which always starts from channel 1.

Save to file and load to file buttons allow the user to save and load files from your won choice of location on the computer. The files are in xml plist format and can be edited by hand if you want. This could be useful for making arbitrary note layouts. Be careful though, as loading a plist with invalid values or typos is likely to cause a crash.

Save and load defaults uses the OSX defaults system to load default settings on startup, or any other time you press load. The settings are not saved automatically. To change the settings used at startup, configure the app how you want, then press “save defaults”, and the program should use those settings on next startup. This is so you can get going quicker if you have a standard setup and just want to play.

The connection status of the Manta is displayed in the menubar by the icon colour. Red icon is connected, blue is disconnected.

The sliders on the Manta send mod wheel and breath controller Midi CC messages. They can’t be changed, although if people need it I could add another menu to select the midi CC number for each slider.

The 4 buttons on the Manta have several functions, all hardwired.

The lower two buttons are increment and decrement, and the upper two act as latching modifiers.

when the upper left button is not set the lower two buttons transpose up and down by an octave. when it is set the tranpose up and down by a semitone.

when the upper right button is set this all changes and the lower 2 buttons trigger midi program change messages, unless the upper left key is set in which case they send bank change messages.

