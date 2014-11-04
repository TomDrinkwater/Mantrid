//  UserData.swift
//  Mantrid
//
import Foundation

class UserData {
    ////////// BLOODY SODDING ENUMS /////////
    enum PressState : String {case PressOff = "PressOff", PressPoly = "PressPoly", PressChan = "PressChan", PressMulti = "PressMulti"}
    enum LEDModeState : String {case LedOff = "LedOff", LedRed = "LedRed", LedBoth = "LedBoth"}
    
    enum sLEDState: String { //I really hate these stupid enums!
        case Off = "Off"
        case Amber = "Amb"
        case Red = "Red"
    }
    //////// ARRAYS //////////////
    var noteLeds: [sLEDState] = [sLEDState.Red, sLEDState.Off, sLEDState.Off, sLEDState.Red, sLEDState.Off, sLEDState.Off,
        sLEDState.Amber, sLEDState.Amber, sLEDState.Off, sLEDState.Off, sLEDState.Off, sLEDState.Off]
    
    //var padLeds = [sLEDState](count: 48, repeatedValue: sLEDState.Off)    //this is used in set leds from notes but a single variable would do?
    var arbLEDs = [sLEDState](count: 48, repeatedValue: sLEDState.Off)
    var padNotes = [Int](count: 49, repeatedValue: 0)//this is recalculated on the fly, shouldn't even be in userData? MOVE
    var arbNotes = [Int](count: 49, repeatedValue: 60)//equivalent to padnotes // copied to and from padnotes to actually use it, this is just the back up.
    //set to middle C to start

    ////// FLAGS //////////
    var settingNotes = false // should these be saved? should always be false when loading setup! MOVE
    var settingLEDs = false // MOVE to manta object?
    
    var arbNotesLayout = false
    var setLEDsArbitrary = false
    var fast = true
    var turbo = false
    var pressureState = PressState.PressPoly // this is the specific variable of that type being declared and initialised
    var ledModeState = LEDModeState.LedBoth
    
   //// user variables ////////
    var thin = 1
    var upRight = 7
    var upLeft = 5
    var basenote = 6//hmm how is this different to transpose?
    var numMultiChannels = 15 //channel 16 is number 15
    var transpose = 0
    var baseChannel = 0
    
     ////////////// FUNCTIONS ///////////////
    let userDefaults = NSUserDefaults.standardUserDefaults()
   
    func saveDefaults(){
        NSUserDefaults.resetStandardUserDefaults()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(thin, forKey: "thin")
        userDefaults.setInteger(upRight, forKey: "upRight")
        userDefaults.setInteger(upLeft, forKey: "upLeft")
        userDefaults.setInteger(basenote, forKey: "basenote")
        userDefaults.setInteger(numMultiChannels, forKey: "numMultiChannels")
        userDefaults.setInteger(transpose, forKey: "transpose")
        userDefaults.setInteger(baseChannel, forKey: "baseChannel")
        
        userDefaults.setBool(arbNotesLayout, forKey: "arbNotesLayout")
        userDefaults.setBool(setLEDsArbitrary, forKey: "setLEDsArbitrary")
        userDefaults.setBool(fast, forKey: "fast")
        userDefaults.setBool(turbo, forKey: "turbo")
        
        let arbNotesNS = arbNotes as NSArray //cast this swift array of int to NSArray
        userDefaults.setObject(arbNotesNS, forKey: "arbNotesNS")
        
        var noteLedsNS: [NSString] = [NSString]() //create an array of NS string with string values for swift enum.
        for i in 0...11 {
            var value : sLEDState = noteLeds[i]
            noteLedsNS.append(value.rawValue)
        }
        userDefaults.setObject(noteLedsNS, forKey: "noteLedsNS")
        
        var arbLEDsNS: [NSString] = [NSString]() //create an array of NS string with string values for swift enum.
        for i in 0...47 {
            var value : sLEDState = arbLEDs[i]
            arbLEDsNS.append(value.rawValue)
        }
        userDefaults.setObject(arbLEDsNS, forKey: "arbLEDsNS")
        
        var pressureStateNS = pressureState.rawValue as NSString
        userDefaults.setObject(pressureStateNS, forKey: "pressureStateNS")
        
        var ledModeStateNS = ledModeState.rawValue as NSString
        userDefaults.setObject(ledModeStateNS, forKey: "ledModeStateNS")
        
        userDefaults.synchronize()
        println("saved user data")
    }//// end save /////////
//////////////////////////////////////////////////////////////////////////
    func loadDefaults(){
        var defaults = NSUserDefaults.standardUserDefaults()
        
        if let pressureStateNS : AnyObject? = defaults.objectForKey("pressureStateNS") {
            if let temp : String? = pressureStateNS as? String {
                let stringValue = temp!
                if let enumValue = PressState(rawValue: stringValue){
                    pressureState = enumValue
                    println("loaded pressureStateNS \(pressureState.rawValue)")
                }
             } else {
                println("failed to load pressureStateNS = \(pressureStateNS)")
            }
        }
        
        if let ledModeStateNS : AnyObject? = defaults.objectForKey("ledModeStateNS") {
            if let temp : String? = ledModeStateNS as? String {
                let stringValue = temp!
                if let enumValue = LEDModeState(rawValue: stringValue){
                    ledModeState = enumValue
                    println("loaded ledModeState \(ledModeState.rawValue)")
                }
            } else {
                println("failed to load ledModeStateNS = \(ledModeStateNS)")
            }
        }

        
        if let arbNotesNS : AnyObject? = defaults.objectForKey("arbNotesNS") {
            if let readArray : [Int]? = arbNotesNS as? [Int] {
                arbNotes = readArray!
                println("loaded arbNotesNS \(arbNotes)")
            } else {
                println("failed to load arbNotesNS = \(arbNotesNS)")
            }
        }
        
        if let optThin : AnyObject? = defaults.objectForKey("thin") { //this is nuts!
            if let temp : NSNumber? = optThin as? NSNumber{
                thin = temp as Int
                println("loaded thin = \(thin)")
            } else {
                println("failed to load thin = \(thin)")
            }
         }
        
        if let optUpRight : AnyObject? = defaults.objectForKey("upRight") { //this is nuts!
            if let temp : NSNumber? = optUpRight as? NSNumber{
                upRight = temp as Int
                println("loaded upRight = \(upRight)")
            } else {
                println("failed to load upRight = \(upRight)")
            }
        }
        
        if let optUpLeft : AnyObject? = defaults.objectForKey("upLeft") { //this is nuts!
            if let temp : NSNumber? = optUpLeft as? NSNumber{
                upLeft = temp as Int
                println("loaded upLeft = \(upLeft)")
            } else {
                println("failed to load upLeft = \(upLeft)")
            }
        }

        transpose = defaults.integerForKey("transpose")// no checking of type
        println("loaded transpose = \(transpose)")
        
        basenote  = defaults.integerForKey("basenote")// no checking of type
        println("loaded basenote = \(basenote)")
        
        numMultiChannels = defaults.integerForKey("numMultiChannels")// no checking of type
        println("loaded numMultiChannels = \(numMultiChannels)")
        
        baseChannel = defaults.integerForKey("baseChannel")// no checking of type
        println("loaded baseChannel = \(baseChannel)")
        
        arbNotesLayout = defaults.boolForKey("arbNotesLayout")// no checking of type
        println("loaded arbNotesLayout = \(arbNotesLayout)")
        
        setLEDsArbitrary = defaults.boolForKey("setLEDsArbitrary")// no checking of type
        println("loaded setLEDsArbitrary = \(setLEDsArbitrary)")
        
        fast = defaults.boolForKey("fast")// no checking of type
        println("loaded fast = \(fast)")
        
        turbo = defaults.boolForKey("turbo")// no checking of type
        println("loaded turbo = \(turbo)")
        
        if let noteLedsNS : AnyObject? = defaults.objectForKey("noteLedsNS") {
            var readArray : [String] = noteLedsNS! as [String]// convert to swift strings?
            println("loaded noteLedsNS \(readArray)")
            for i in 0...11 {
                if let value  = sLEDState(rawValue: readArray[i]){//value will be optional. if user edits plist and misspells the tag it will fail
                    noteLeds[i] = value // the if binding means don't have to unwrap with !
                }//convert each element back to a optional swift enum
            }
            println("converted noteLedsNS")
            for i in 0...11 {
                print(" \(noteLeds[i].rawValue)")
            }
        } else {
            println("failed to read noteLedsNS")
        }
        
        if let arbLEDsNS : AnyObject? = defaults.objectForKey("arbLEDsNS") {
            var readArray : [String] = arbLEDsNS! as [String]// convert to swift strings?
            println("loaded arbLEDsNS \(readArray)")
            for i in 0...47 {
                if let value  = sLEDState(rawValue: readArray[i]){//value will be optional. if user edits plist and misspells the tag it will fail
                    arbLEDs[i] = value // the if binding means don't have to unwrap with !
                }//convert each element back to a optional swift enum
            }
            println("converted arbLEDsNS")
            for i in 0...47 {
                print(" \(arbLEDs[i].rawValue)")
            }
        } else {
            println("failed to read arbLEDsNS")
        }
        
        
    }//end loadDefaults
    
    init() {
        setIsoNotes()
    }
    
    func setIsoNotes() {
        var thisrowoffset = 0
        var nextPad = upRight - upLeft
        var rownumber = 0
        var j = 0
        padNotes[j] = (36 + transpose + basenote)//set first note
        ++j
        for i in 0...5 {//loop 6 times for 6 rows
            for k in 0...6 {//7 remaining pads per row
                padNotes[j] = (padNotes[j-1] + nextPad)
                ++j //next pad
            }//end pad loop
            rownumber = Int((j-1)/8)//why not just ++rownumber
            if ((rownumber % 2) == 1 ) {  // if odd num row
                thisrowoffset = upLeft
            } else {               //else even num  row
                thisrowoffset = upRight
            }
            padNotes[j] = (padNotes[j-8] + thisrowoffset)//does first note of new row //THIS IS AN OUT BY ONE ERROR requires array to be one bigger
            ++j
        }//end outer loop
       // for note in padNotes {println(note)}
    }// end setIsonotes
    
    
    func setArbNotes() {
        for i in 0...47 {
            padNotes[i] = arbNotes[i] + transpose
        }//basenote doesn't really apply to arbnotes
    }
    
    func makeLedLabelText()-> String{
        var ledLabelText = ""
        if setLEDsArbitrary {// this is clumsy!
            for i in 40...47{//line 6
                ledLabelText += "\(arbLEDs[i].rawValue) "
            }
            ledLabelText += "\r"
            for i in 32...39{
                ledLabelText += "\(arbLEDs[i].rawValue) "
            }
            ledLabelText += "\r"
            for i in 24...31{
                ledLabelText += "\(arbLEDs[i].rawValue) "
            }
            ledLabelText += "\r"
            for i in 16...23{
                ledLabelText += "\(arbLEDs[i].rawValue) "
            }
            ledLabelText += "\r"
            for i in 8...15{
                ledLabelText += "\(arbLEDs[i].rawValue) "
            }
            ledLabelText += "\r"
            for i in 0...7{
                ledLabelText += "\(arbLEDs[i].rawValue) "
            }
        } else {
            ledLabelText = ("A- \(noteLeds[0].rawValue) Bb-\(noteLeds[1].rawValue) B- \(noteLeds[2].rawValue) C- \(noteLeds[3].rawValue) \rC#-\(noteLeds[4].rawValue) D- \(noteLeds[5].rawValue) Eb-\(noteLeds[6].rawValue) E- \(noteLeds[7].rawValue) \rF- \(noteLeds[8].rawValue) F#-\(noteLeds[9].rawValue) G- \(noteLeds[10].rawValue) G#-\(noteLeds[11].rawValue)")
        }
        return ledLabelText
    }
    
    func makeNoteLabelText() -> String{
        var noteLabelText = ""
        for i in 40...47{//line 6
            if padNotes[i] < 100 {noteLabelText += " "}
            noteLabelText += "\(padNotes[i]) "
        }
        noteLabelText += "\r"
        for i in 32...39{
            if padNotes[i] < 100 {noteLabelText += " "}
            noteLabelText += "\(padNotes[i]) "
        }
        noteLabelText += "\r"
        for i in 24...31{
            if padNotes[i] < 100 {noteLabelText += " "}
            noteLabelText += "\(padNotes[i]) "
        }
        noteLabelText += "\r"
        for i in 16...23{
            if padNotes[i] < 100 {noteLabelText += " "}
            noteLabelText += "\(padNotes[i]) "
        }
        noteLabelText += "\r"
        for i in 8...15{
            if padNotes[i] < 100 {noteLabelText += " "}
            noteLabelText += "\(padNotes[i]) "
        }
        noteLabelText += "\r"
        for i in 0...7{
            if padNotes[i] < 100 {noteLabelText += " "}
            noteLabelText += "\(padNotes[i]) "
        }
        return noteLabelText
    }

    
    
    
    
    
}//end userdata

